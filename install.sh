#!/bin/sh

mkdir -p ~/.config/

ln -s ~/.dotfiles/bashrc ~/.bashrc
ln -s ~/.dotfiles/bash_aliases ~/.bash_aliases
ln -s ~/.dotfiles/bash_profile ~/.bash_profile
ln -s ~/.dotfiles/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/gitignore ~/.gitignore
ln -s ~/.dotfiles/tigrc ~/.tigrc
ln -s ~/.dotfiles/ripgreprc ~/.ripgreprc
ln -s ~/.dotfiles/psqlrc ~/.psqlrc
ln -s ~/.dotfiles/xinitrc ~/.xinitrc
ln -s ~/.dotfiles/pqivrc ~/.pqivrc
ln -s ~/.dotfiles/bat ~/.config/
ln -s ~/.dotfiles/mutt ~/.config/
ln -s ~/.dotfiles/mailcap ~/.mailcap
ln -s ~/.dotfiles/tmux ~/.config/
ln -s ~/.dotfiles/tmux/tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/alacritty ~/.config/
ln -s ~/.dotfiles/ghostty ~/.config/
mkdir -p ~/.config/herdr
ln -sf ~/.dotfiles/herdr/config.toml ~/.config/herdr/config.toml
ln -s ~/.dotfiles/mostrc ~/.mostrc
ln -s ~/.dotfiles/gpg-agent.conf ~/.gnupg/gpg-agent.conf
ln -s ~/.dotfiles/ctags.d ~/.ctags.d

# vkq (Vikunja quick capture); put the API token in ~/.config/vkq/token (chmod 600)
mkdir -p ~/.local/bin ~/.config/vkq
ln -sf ~/.dotfiles/bin/vkq ~/.local/bin/vkq
ln -sf ~/.dotfiles/vkq/config.example.toml ~/.config/vkq/config.toml


mkdir -p ~/.cache/awesome
ln -s ~/.dotfiles/awesome ~/.config/

# Emulation (ES-DE over the omv library); packages and details in kb workstation/emulation.md
mkdir -p ~/.config/retroarch/autoconfig/sdl2 ~/.config/PCSX2/inis ~/ES-DE/settings ~/ES-DE/themes
ln -sf ~/.dotfiles/emulation/retroarch/retroarch.cfg ~/.config/retroarch/retroarch.cfg
ln -sf ~/.dotfiles/emulation/retroarch/autoconfig/sdl2/8BitDo_Ultimate_2_Wireless.cfg ~/.config/retroarch/autoconfig/sdl2/
# PCSX2 and ES-DE rewrite their settings files: seed them once instead of linking
[ -e ~/.config/PCSX2/inis/PCSX2.ini ] || cp ~/.dotfiles/emulation/pcsx2/PCSX2.ini ~/.config/PCSX2/inis/
[ -e ~/ES-DE/settings/es_settings.xml ] || cp ~/.dotfiles/emulation/es-de/es_settings.xml ~/ES-DE/settings/
[ -d ~/ES-DE/themes/art-book-next-es-de ] || git clone --depth 1 https://github.com/anthonycaccese/art-book-next-es-de.git ~/ES-DE/themes/art-book-next-es-de
[ -d /mnt/omv/Games/ROMs ] && ~/.dotfiles/emulation/es-de-setup.py
