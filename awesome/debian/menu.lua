-- automatically generated file. Do not edit (see /usr/share/doc/menu/html)

module("debian.menu")

Debian_menu = {}

Debian_menu["Debian_Aplikacje_Biuro"] = {
	{"LibreOffice Calc","/usr/bin/libreoffice --calc","/usr/share/icons/hicolor/32x32/apps/libreoffice-calc.xpm"},
	{"LibreOffice Impress","/usr/bin/libreoffice --impress","/usr/share/icons/hicolor/32x32/apps/libreoffice-impress.xpm"},
	{"LibreOffice Writer","/usr/bin/libreoffice --writer","/usr/share/icons/hicolor/32x32/apps/libreoffice-writer.xpm"},
}
Debian_menu["Debian_Aplikacje_Dostępność"] = {
	{"kvkbd","/usr/bin/kvkbd","/usr/share/pixmaps/kvkbd.xpm"},
	{"Xmag","xmag"},
}
Debian_menu["Debian_Aplikacje_Dźwięk"] = {
	{"Audacious","/usr/bin/audacious"},
}
Debian_menu["Debian_Aplikacje_Edytory"] = {
	{"GVIM","/usr/bin/vim.gtk -g -f","/usr/share/pixmaps/vim-32.xpm"},
	{"Nano", "x-terminal-emulator -e ".."/bin/nano","/usr/share/nano/nano-menu.xpm"},
	{"Xedit","xedit"},
}
Debian_menu["Debian_Aplikacje_Grafika"] = {
	{"LibreOffice Draw","/usr/bin/libreoffice --draw","/usr/share/icons/hicolor/32x32/apps/libreoffice-draw.xpm"},
	{"The GIMP","/usr/bin/gimp","/usr/share/pixmaps/gimp.xpm"},
	{"X Window Snapshot","xwd | xwud"},
}
Debian_menu["Debian_Aplikacje_Nauki_ścisłe_Matematyka"] = {
	{"Bc", "x-terminal-emulator -e ".."/usr/bin/bc"},
	{"Dc", "x-terminal-emulator -e ".."/usr/bin/dc"},
	{"LibreOffice Math","/usr/bin/libreoffice --math","/usr/share/icons/hicolor/32x32/apps/libreoffice-math.xpm"},
	{"Xcalc","xcalc"},
}
Debian_menu["Debian_Aplikacje_Nauki_ścisłe"] = {
	{ "Matematyka", Debian_menu["Debian_Aplikacje_Nauki_ścisłe_Matematyka"] },
}
Debian_menu["Debian_Aplikacje_Powłoki"] = {
	{"Bash", "x-terminal-emulator -e ".."/bin/bash --login"},
	{"Dash", "x-terminal-emulator -e ".."/bin/dash -i"},
	{"Sh", "x-terminal-emulator -e ".."/bin/sh --login"},
}
Debian_menu["Debian_Aplikacje_Programowanie"] = {
	{"GDB", "x-terminal-emulator -e ".."/usr/bin/gdb"},
	{"Python (v2.7)", "x-terminal-emulator -e ".."/usr/bin/python2.7","/usr/share/pixmaps/python2.7.xpm"},
	{"Ruby (irb1.9.1)", "x-terminal-emulator -e ".."/usr/bin/irb1.9.1"},
	{"Tclsh8.5", "x-terminal-emulator -e ".."/usr/bin/tclsh8.5"},
}
Debian_menu["Debian_Aplikacje_Przeglądarki"] = {
	{"Xditview","xditview"},
}
Debian_menu["Debian_Aplikacje_Sieć_Komunikacja"] = {
	{"Irssi", "x-terminal-emulator -e ".."/usr/bin/irssi"},
	{"Mutt", "x-terminal-emulator -e ".."/usr/bin/mutt","/usr/share/pixmaps/mutt.xpm"},
	{"Pidgin","/usr/bin/pidgin","/usr/share/pixmaps/pidgin-menu.xpm"},
	{"Telnet", "x-terminal-emulator -e ".."/usr/bin/telnet"},
	{"Xbiff","xbiff"},
}
Debian_menu["Debian_Aplikacje_Sieć_Przeglądanie_WWW"] = {
	{"Lynx-cur", "x-terminal-emulator -e ".."lynx"},
}
Debian_menu["Debian_Aplikacje_Sieć_Przesyłanie_plików"] = {
	{"QNapi","/usr/bin/qnapi","/usr/share/icons/qnapi-32.xpm"},
}
Debian_menu["Debian_Aplikacje_Sieć"] = {
	{ "Komunikacja", Debian_menu["Debian_Aplikacje_Sieć_Komunikacja"] },
	{ "Przeglądanie WWW", Debian_menu["Debian_Aplikacje_Sieć_Przeglądanie_WWW"] },
	{ "Przesyłanie plików", Debian_menu["Debian_Aplikacje_Sieć_Przesyłanie_plików"] },
}
Debian_menu["Debian_Aplikacje_Systemowe_Administracja"] = {
	{"Debian Task selector", "x-terminal-emulator -e ".."su-to-root -c tasksel"},
	{"DSL/PPPoE configuration tool", "x-terminal-emulator -e ".."/usr/sbin/pppoeconf","/usr/share/pixmaps/pppoeconf.xpm"},
	{"Editres","editres"},
	{"GNOME partition editor","su-to-root -X -c /usr/sbin/gparted","/usr/share/pixmaps/gparted.xpm"},
	{"pppconfig", "x-terminal-emulator -e ".."su-to-root -p root -c /usr/sbin/pppconfig"},
	{"Xclipboard","xclipboard"},
	{"Xfontsel","xfontsel"},
	{"Xkill","xkill"},
	{"Xrefresh","xrefresh"},
}
Debian_menu["Debian_Aplikacje_Systemowe_Monitorowanie"] = {
	{"htop", "x-terminal-emulator -e ".."/usr/bin/htop"},
	{"Pstree", "x-terminal-emulator -e ".."/usr/bin/pstree.x11","/usr/share/pixmaps/pstree16.xpm"},
	{"Top", "x-terminal-emulator -e ".."/usr/bin/top"},
	{"Xconsole","xconsole -file /dev/xconsole"},
	{"Xev","x-terminal-emulator -e xev"},
	{"Xload","xload"},
}
Debian_menu["Debian_Aplikacje_Systemowe_Sprzęt"] = {
	{"Xvidtune","xvidtune"},
}
Debian_menu["Debian_Aplikacje_Systemowe_Ustawienia_języka"] = {
	{"Input Method Swicher", "x-terminal-emulator -e ".."/usr/bin/im-switch"},
}
Debian_menu["Debian_Aplikacje_Systemowe_Zarządzanie_pakietami"] = {
	{"Aptitude Package Manager (text)", "x-terminal-emulator -e ".."/usr/bin/aptitude-curses"},
}
Debian_menu["Debian_Aplikacje_Systemowe"] = {
	{ "Administracja", Debian_menu["Debian_Aplikacje_Systemowe_Administracja"] },
	{ "Monitorowanie", Debian_menu["Debian_Aplikacje_Systemowe_Monitorowanie"] },
	{ "Sprzęt", Debian_menu["Debian_Aplikacje_Systemowe_Sprzęt"] },
	{ "Ustawienia języka", Debian_menu["Debian_Aplikacje_Systemowe_Ustawienia_języka"] },
	{ "Zarządzanie pakietami", Debian_menu["Debian_Aplikacje_Systemowe_Zarządzanie_pakietami"] },
}
Debian_menu["Debian_Aplikacje_Video"] = {
	{"UMPlayer","umplayer","/usr/share/pixmaps/umplayer.xpm"},
	{"VLC media player","/usr/bin/qvlc","/usr/share/icons/hicolor/32x32/apps/vlc.xpm"},
}
Debian_menu["Debian_Aplikacje_Zarządzanie_danymi"] = {
	{"ABook", "x-terminal-emulator -e ".."/usr/bin/abook"},
}
Debian_menu["Debian_Aplikacje_Zarządzanie_plikami"] = {
	{"K3b","/usr/bin/k3b","/usr/share/pixmaps/k3b.xpm"},
	{"mc", "x-terminal-emulator -e ".."/usr/bin/mc","/usr/share/pixmaps/mc.xpm"},
}
Debian_menu["Debian_Aplikacje"] = {
	{ "Biuro", Debian_menu["Debian_Aplikacje_Biuro"] },
	{ "Dostępność", Debian_menu["Debian_Aplikacje_Dostępność"] },
	{ "Dźwięk", Debian_menu["Debian_Aplikacje_Dźwięk"] },
	{ "Edytory", Debian_menu["Debian_Aplikacje_Edytory"] },
	{ "Grafika", Debian_menu["Debian_Aplikacje_Grafika"] },
	{ "Nauki ścisłe", Debian_menu["Debian_Aplikacje_Nauki_ścisłe"] },
	{ "Powłoki", Debian_menu["Debian_Aplikacje_Powłoki"] },
	{ "Programowanie", Debian_menu["Debian_Aplikacje_Programowanie"] },
	{ "Przeglądarki", Debian_menu["Debian_Aplikacje_Przeglądarki"] },
	{ "Sieć", Debian_menu["Debian_Aplikacje_Sieć"] },
	{ "Systemowe", Debian_menu["Debian_Aplikacje_Systemowe"] },
	{ "Video", Debian_menu["Debian_Aplikacje_Video"] },
	{ "Zarządzanie danymi", Debian_menu["Debian_Aplikacje_Zarządzanie_danymi"] },
	{ "Zarządzanie plikami", Debian_menu["Debian_Aplikacje_Zarządzanie_plikami"] },
}
Debian_menu["Debian_Gry_Karciane"] = {
	{"KDE Patience","/usr/games/kpat"},
}
Debian_menu["Debian_Gry_Zabawki"] = {
	{"Oclock","oclock"},
	{"Xclock (analog)","xclock -analog"},
	{"Xclock (digital)","xclock -digital -update 1"},
	{"Xeyes","xeyes"},
	{"Xlogo","xlogo"},
}
Debian_menu["Debian_Gry_Zręcznościowe"] = {
	{"OpenArena","/usr/games/openarena","/usr/share/pixmaps/openarena32.xpm"},
}
Debian_menu["Debian_Gry"] = {
	{ "Karciane", Debian_menu["Debian_Gry_Karciane"] },
	{ "Zabawki", Debian_menu["Debian_Gry_Zabawki"] },
	{ "Zręcznościowe", Debian_menu["Debian_Gry_Zręcznościowe"] },
}
Debian_menu["Debian_Pomoc"] = {
	{"Info", "x-terminal-emulator -e ".."info"},
	{"Xman","xman"},
}
Debian_menu["Debian"] = {
	{ "Aplikacje", Debian_menu["Debian_Aplikacje"] },
	{ "Gry", Debian_menu["Debian_Gry"] },
	{ "Pomoc", Debian_menu["Debian_Pomoc"] },
}
