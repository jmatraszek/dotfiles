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
      copied from the share once (names, descriptions); ES-DE keeps play
      counts in it, so --refresh-gamelists overwrites them
  ~/.config/retroarch/cores/<core>_libretro.so
      the default core of every system, from the libretro buildbot, when missing

ES-DE itself never writes to the share.
"""
import argparse
import copy
import io
import os
import re
import shutil
import urllib.request
import zipfile
import xml.etree.ElementTree as ET
from pathlib import Path

ROMS = Path("/mnt/omv/Games/ROMs")
SAVES = Path("/mnt/syncthing/retro-saves")
BUNDLED = Path("/usr/share/es-de/resources/systems/linux/es_systems.xml")
HOME = Path.home()
ESDE = HOME / "ES-DE"
RA_CFG = HOME / ".config/retroarch/es-de"
RA_CORES = HOME / ".config/retroarch/cores"
BUILDBOT = "https://buildbot.libretro.com/nightly/linux/x86_64/latest"
MEDIA = ("covers", "screenshots", "manuals")

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
    parser.add_argument(
        "--refresh-gamelists",
        action="store_true",
        help="overwrite the local gamelists with the share's (drops play counts)",
    )
    args = parser.parse_args()

    bundled = {
        s.findtext("name"): s for s in ET.parse(BUNDLED).getroot().findall("system")
    }
    present = {p.name for p in ROMS.iterdir() if p.is_dir()}
    out = ET.Element("systemList")
    RA_CFG.mkdir(parents=True, exist_ok=True)

    for bat, (name, label) in sorted(SYSTEMS.items()):
        if bat not in present:
            continue
        out.append(custom_system(bundled[name], bat, label))

        saves = SAVES / bat
        (RA_CFG / f"{bat}.cfg").write_text(
            f'savefile_directory = "{saves}"\nsavestate_directory = "{saves}"\n'
        )

        for kind in MEDIA:
            if (ROMS / bat / kind).is_dir():
                link(ROMS / bat / kind, ESDE / "downloaded_media" / name / kind)

        source = ROMS / bat / "gamelist.xml"
        target = ESDE / "gamelists" / name / "gamelist.xml"
        if source.is_file() and (args.refresh_gamelists or not target.exists()):
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)

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
