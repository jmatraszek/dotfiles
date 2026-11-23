#!/usr/bin/env python3
"""ES-DE on the desktop, playing the omv library in place.

ROMs, BIOS and saves all live on omv, shared with Batocera and the handhelds:
  ROMs   /mnt/omv/Games/ROMs/<batocera system>   (curated library, RomM)
  BIOS   /mnt/omv/Games/BIOS                     (Batocera layout)
  Saves  /mnt/syncthing/retro-saves/<system>     (Syncthing folder retro-saves)

What it writes (rerun after RomM adds systems or games):
  ~/ES-DE/custom_systems/es_systems.xml  ES-DE systems pointed at Batocera's
      folder names; RetroArch gets a per-system config with the save folders
  ~/.config/retroarch/es-de/<system>.cfg
  ~/ES-DE/downloaded_media/<es system>/{covers,screenshots,manuals}
      symlinks to the media RomM exports next to the ROMs
  ~/ES-DE/gamelists/<es system>/gamelist.xml
      the share's gamelist (RomM exports names, descriptions, media and hides
      non-games), keeping what ES-DE tracks locally: play count, last played,
      favourite
  ~/.config/retroarch/cores/<core>_libretro.so
      the default core of every system, from the libretro buildbot, when missing
  /mnt/omv/Games/Decorations/<set>/systems/<bezel>.{png,info}
      Batocera's bezel of every system, downloaded once; the per-system
      RetroArch config shows it as an overlay with the game inside its window
  ~/.config/retroarch/config/<core>/<system>.slangp
      CRT shader for the 2D home systems (RetroArch's per-folder preset)

ES-DE itself never writes to the share; this script only adds the bezels.
"""
import argparse
import copy
import io
import os
import json
import re
import subprocess
import urllib.error
import urllib.parse
import urllib.request
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROMS = Path("/mnt/omv/Games/ROMs")
SAVES = Path("/mnt/syncthing/retro-saves")
BIOS = Path("/mnt/omv/Games/BIOS")
BUNDLED = Path("/usr/share/es-de/resources/systems/linux/es_systems.xml")
HOME = Path.home()
SCUMMVM_LAUNCH = Path(__file__).resolve().parent / "scummvm-launch"
ESDE = HOME / "ES-DE"
RA_CFG = HOME / ".config/retroarch/es-de"
RA_CORES = HOME / ".config/retroarch/cores"
BUILDBOT = "https://buildbot.libretro.com/nightly/linux/x86_64/latest"
MEDIA = ("covers", "screenshots", "manuals")
RA_CONFIG = HOME / ".config/retroarch/config"
CORE_INFO = Path("/usr/share/libretro/info")
# Batocera's bezels (batocera-linux/batocera-bezel), flat screen variant. Each
# .info gives the game window in a 1920x1080 frame.
BEZELS = Path("/mnt/omv/Games/Decorations")
BEZEL_SET = "default_nocurve"
BEZEL_URL = "https://raw.githubusercontent.com/batocera-linux/batocera-bezel/master"
# Batocera folder -> bezel name, where they differ. Systems without a bezel
# (arcade, nds, psp, computers run windowed) play full screen.
BEZEL_ALIASES = {
    "amiga1200": "amiga500",
    "fds": "nes",
    "o2em": "odyssey2",
    "satellaview": "snes",
    "segacd": "megacd",
    "sufami": "snes",
}
# Systems whose BIOS sits in a subfolder of BIOS/ (Batocera layout) and whose
# core looks only in the system folder root: PUAE wants the Kickstarts there,
# or it falls back to AROS and WHDLoad (.lha) games fail
SYSTEM_DIRS = {"amiga500": "amiga", "amiga1200": "amiga"}
NO_BEZEL = {"dos", "fbneo", "mame", "nds", "psp", "xbox", "c20", "daphne"}
# 2D home systems that get a light CRT shader (the GTX 750 Ti cannot run the
# heavy ones at 1440p). Handhelds and 3D systems stay clean.
CRT_SHADER = "/usr/share/libretro/shaders/shaders_slang/crt/crt-easymode.slangp"
CRT_SYSTEMS = {
    "amiga500", "amiga1200", "amstradcpc", "atari2600", "atari5200", "atari7800",
    "atari800", "atarist", "c64", "colecovision", "fds", "intellivision",
    "mastersystem", "megadrive", "msx1", "msx2", "neogeo", "nes", "o2em",
    "pcengine", "pcenginecd", "satellaview", "sega32x", "segacd", "sg1000",
    "snes", "sufami", "supergrafx", "zxspectrum",
}
# Per-game fields ES-DE writes on the desktop; kept across refreshes from the share
LOCAL_FIELDS = ("playcount", "lastplayed", "favorite")
# File a game folder launches directly (ES-DE folder link): the .m3u of a
# multi-disc game, the .scummvm of a ScummVM game
FOLDER_LINK_EXTENSIONS = (".m3u", ".scummvm")

# Batocera folder -> (ES-DE system, preferred emulator label or None for ES-DE's
# default). Cores follow Batocera's defaults where saves would otherwise not
# carry over between the two.
SYSTEMS = {
    "3do": ("3do", None),
    "amiga500": ("amiga", None),
    "amiga1200": ("amiga1200", None),
    "amstradcpc": ("amstradcpc", None),
    "arcadia": ("arcadia", None),
    "atari2600": ("atari2600", None),
    "atari5200": ("atari5200", None),
    "atari7800": ("atari7800", None),
    "atari800": ("atari800", None),
    "atarist": ("atarist", None),
    "c20": ("vic20", None),
    "c64": ("c64", None),
    "cdi": ("cdimono1", None),
    "channelf": ("channelf", None),
    "colecovision": ("colecovision", None),
    "crvision": ("crvision", None),
    "daphne": ("daphne", None),
    "dos": ("dos", None),
    "dreamcast": ("dreamcast", None),
    "fbneo": ("fbneo", None),
    "fds": ("fds", "FCEUmm"),
    "gameandwatch": ("gameandwatch", None),
    "gamecube": ("gc", "Dolphin (Standalone)"),
    "gamegear": ("gamegear", None),
    "gb": ("gb", None),
    "gba": ("gba", None),
    "gbc": ("gbc", None),
    "intellivision": ("intellivision", None),
    "jaguar": ("atarijaguar", None),
    "lynx": ("atarilynx", None),
    "mame": ("mame", None),
    "mastersystem": ("mastersystem", None),
    "megadrive": ("megadrive", None),
    "msx1": ("msx1", None),
    "msx2": ("msx2", None),
    "n64": ("n64", None),
    "nds": ("nds", None),
    "neogeo": ("neogeo", None),
    "nes": ("nes", "FCEUmm"),
    "ngpc": ("ngpc", None),
    "o2em": ("odyssey2", None),
    "pcengine": ("pcengine", None),
    "pcenginecd": ("pcenginecd", None),
    "prboom": ("doom", None),
    "ps2": ("ps2", "PCSX2 (Standalone)"),
    "psp": ("psp", "PPSSPP (Standalone)"),
    "psx": ("psx", "Beetle PSX HW"),
    "satellaview": ("satellaview", None),
    "saturn": ("saturn", None),
    "scummvm": ("scummvm", "ScummVM (Standalone)"),
    "sega32x": ("sega32x", None),
    "segacd": ("segacd", None),
    "sg1000": ("sg-1000", None),
    "snes": ("snes", None),
    "sufami": ("sufami", None),
    "supergrafx": ("supergrafx", None),
    "vectrex": ("vectrex", None),
    "virtualboy": ("virtualboy", None),
    "wswan": ("wonderswan", None),
    "wswanc": ("wonderswancolor", None),
    "x68000": ("x68000", None),
    "xbox": ("xbox", None),
    "zxspectrum": ("zxspectrum", None),
}


def custom_system(bundled, bat, label):
    system = copy.deepcopy(bundled)
    system.find("path").text = str(ROMS / bat)
    commands = system.findall("command")
    if label:
        chosen = [c for c in commands if c.get("label") == label]
        if not chosen:
            raise SystemExit(f"{bat}: no emulator labelled {label!r}")
        # ES-DE takes the first command as the default; keep the others as
        # alternatives in the same order.
        index = list(system).index(commands[0])
        for c in commands:
            system.remove(c)
        ordered = chosen[:1] + [c for c in commands if c is not chosen[0]]
        for offset, c in enumerate(ordered):
            system.insert(index + offset, c)
    for c in system.findall("command"):
        if c.get("label") == "ScummVM (Standalone)":
            # ES-DE wants <short name>.scummvm files; Batocera's carry the short
            # name inside, so a wrapper reads it.
            c.text = f"{SCUMMVM_LAUNCH} %ROM%"
    cfg = RA_CFG / f"{bat}.cfg"
    for c in system.findall("command"):
        if c.text and "%EMULATOR_RETROARCH%" in c.text:
            c.text = c.text.replace(
                "%EMULATOR_RETROARCH%",
                f"%EMULATOR_RETROARCH% --appendconfig {cfg}",
                1,
            )
    return system


def fetch_cores(systems):
    """Download the default RetroArch core of each system if it is missing."""
    RA_CORES.mkdir(parents=True, exist_ok=True)
    for system in systems:
        match = re.search(r"%CORE_RETROARCH%/(\w+_libretro\.so)", system.find("command").text)
        if not match or (RA_CORES / match.group(1)).exists():
            continue
        core = match.group(1)
        print(f"fetch {core}")
        with urllib.request.urlopen(f"{BUILDBOT}/{core}.zip") as response:
            zipfile.ZipFile(io.BytesIO(response.read())).extract(core, RA_CORES)


def screen_size():
    """Resolution of the primary monitor, where games run (HDMI-0)."""
    try:
        out = subprocess.run(["xrandr", "--query"], capture_output=True, text=True).stdout
        match = re.search(r" connected primary (\d+)x(\d+)", out)
        if match:
            return int(match.group(1)), int(match.group(2))
    except FileNotFoundError:
        pass
    return 2560, 1440


def fetch_bezel(path):
    """A file from the bezel repo, following its git symlinks, or None."""
    for _ in range(5):
        try:
            with urllib.request.urlopen(f"{BEZEL_URL}/{urllib.parse.quote(path)}") as response:
                data = response.read()
        except urllib.error.HTTPError:
            return None
        # A git symlink comes back as its target path
        if len(data) > 256 or data[:1] == b"{" or data.startswith(b"\x89PNG"):
            return data
        path = os.path.normpath(os.path.join(os.path.dirname(path), data.decode().strip()))
    return None


def bezel(bat, screen):
    """RetroArch settings showing the system's bezel, or [] if it has none."""
    name = BEZEL_ALIASES.get(bat, bat)
    if bat in NO_BEZEL:
        return []
    base = BEZELS / BEZEL_SET / "systems" / name
    for ext in ("png", "info"):
        path = base.with_suffix(f".{ext}")
        if path.exists():
            continue
        data = fetch_bezel(f"{BEZEL_SET}/systems/{name}.{ext}")
        if data is None:
            return []
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(data)
        print(f"bezel {path.name}")
    info = json.loads(base.with_suffix(".info").read_text())
    overlay = RA_CFG / "overlays" / f"{bat}.cfg"
    overlay.parent.mkdir(exist_ok=True)
    overlay.write_text(
        "overlays = 1\n"
        f'overlay0_overlay = "{base.with_suffix(".png")}"\n'
        "overlay0_full_screen = true\n"
        "overlay0_descs = 0\n"
    )
    # The game window from the 1920x1080 .info, scaled to the screen
    sx, sy = screen[0] / info["width"], screen[1] / info["height"]
    return [
        'input_overlay_enable = "true"',
        f'input_overlay = "{overlay}"',
        'input_overlay_opacity = "1.000000"',
        'input_overlay_hide_in_menu = "true"',
        'video_scale_integer = "false"',
        'aspect_ratio_index = "23"',  # custom viewport
        # Anchor top left: RetroArch otherwise centres the viewport and adds x/y
        'video_viewport_bias_x = "0.000000"',
        'video_viewport_bias_y = "0.000000"',
        f'custom_viewport_x = "{round(info["left"] * sx)}"',
        f'custom_viewport_y = "{round(info["top"] * sy)}"',
        f'custom_viewport_width = "{round((info["width"] - info["left"] - info["right"]) * sx)}"',
        f'custom_viewport_height = "{round((info["height"] - info["top"] - info["bottom"]) * sy)}"',
    ]


def crt_shader(bat, system):
    """Per-folder shader preset: RetroArch loads config/<core>/<folder>.slangp."""
    match = re.search(r"%CORE_RETROARCH%/(\w+)_libretro\.so", system.find("command").text or "")
    info = CORE_INFO / f"{match.group(1)}_libretro.info" if match else None
    if not info or not info.exists():
        return
    core = re.search(r'^corename = "(.*)"', info.read_text(), re.M).group(1)
    preset = RA_CONFIG / core / f"{bat}.slangp"
    preset.parent.mkdir(parents=True, exist_ok=True)
    preset.write_text(f'#reference "{CRT_SHADER}"\n')


def folder_link(folder):
    """The file inside a game folder ES-DE should launch, or None."""
    files = sorted(
        f.name for f in folder.iterdir() if f.suffix.lower() in FOLDER_LINK_EXTENSIONS
    )
    # Several .scummvm files are language versions: prefer the English one
    english = [f for f in files if "english" in f.lower()]
    return (english or files or [None])[0]


def merge_gamelist(source, target, system_dir):
    """Write the share's gamelist to target, keeping ES-DE's local fields.

    RomM exports game folders (multi-disc, ScummVM) as <game>, which ES-DE skips
    as a "Game/folder mismatch": they become <folder> entries with a folder link.
    """
    local = {}
    if target.exists():
        for game in ET.parse(target).getroot().iter("game"):
            local[game.findtext("path")] = {
                f: game.findtext(f) for f in LOCAL_FIELDS if game.find(f) is not None
            }
    tree = ET.parse(source)
    for game in tree.getroot().iter("game"):
        for field, value in local.get(game.findtext("path"), {}).items():
            element = game.find(field)
            if element is None:
                element = ET.SubElement(game, field)
            element.text = value
        # Only folders with a file to launch: a folder named like a game file
        # (lair.daphne/) is a game to ES-DE already.
        folder = system_dir / game.findtext("path", "")
        link = folder_link(folder) if game.findtext("path") and folder.is_dir() else None
        if link:
            game.tag = "folder"
            ET.SubElement(game, "folderlink").text = link
    target.parent.mkdir(parents=True, exist_ok=True)
    tree.write(target, encoding="utf-8", xml_declaration=True)


def link(target, path):
    if path.is_symlink():
        if os.readlink(path) == str(target):
            return
        path.unlink()
    elif path.exists():
        print(f"skip {path}: exists and is not a symlink")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.symlink_to(target)


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.parse_args()

    bundled = {
        s.findtext("name"): s for s in ET.parse(BUNDLED).getroot().findall("system")
    }
    present = {p.name for p in ROMS.iterdir() if p.is_dir()}
    out = ET.Element("systemList")
    RA_CFG.mkdir(parents=True, exist_ok=True)
    screen = screen_size()

    for bat, (name, label) in sorted(SYSTEMS.items()):
        if bat not in present:
            continue
        system = custom_system(bundled[name], bat, label)
        out.append(system)

        # RetroArch silently falls back to its own folders when these are missing
        saves = SAVES / bat
        saves.mkdir(exist_ok=True)
        lines = [f'savefile_directory = "{saves}"', f'savestate_directory = "{saves}"']
        if bat in SYSTEM_DIRS:
            lines.append(f'system_directory = "{BIOS / SYSTEM_DIRS[bat]}"')
        (RA_CFG / f"{bat}.cfg").write_text("\n".join(lines + bezel(bat, screen)) + "\n")
        if bat in CRT_SYSTEMS:
            crt_shader(bat, system)

        for kind in MEDIA:
            if (ROMS / bat / kind).is_dir():
                link(ROMS / bat / kind, ESDE / "downloaded_media" / name / kind)

        source = ROMS / bat / "gamelist.xml"
        target = ESDE / "gamelists" / name / "gamelist.xml"
        if source.is_file():
            merge_gamelist(source, target, ROMS / bat)

    for bat in sorted(present - SYSTEMS.keys()):
        print(f"not in ES-DE: {bat}")

    fetch_cores(out)

    ET.indent(out)
    path = ESDE / "custom_systems" / "es_systems.xml"
    path.parent.mkdir(parents=True, exist_ok=True)
    ET.ElementTree(out).write(path, encoding="utf-8", xml_declaration=True)
    print(f"{len(out)} systems -> {path}")


if __name__ == "__main__":
    main()
