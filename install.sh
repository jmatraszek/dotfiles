#!/bin/sh

ln -s ~/.dotfiles/bashrc ~/.bashrc
ln -s ~/.dotfiles/bash_aliases ~/.bash_aliases
ln -s ~/.dotfiles/bash_profile ~/.bash_profile
ln -s ~/.dotfiles/gitconfig ~/.gitconfig
ln -s ~/.dotfiles/gitignore ~/.gitignore
ln -s ~/.dotfiles/tigrc ~/.tigrc
ln -s ~/.dotfiles/psqlrc ~/.psqlrc
ln -s ~/.dotfiles/tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/xinitrc ~/.xinitrc
ln -s ~/.dotfiles/pqivrc ~/.pqivrc
ln -s ~/.dotfiles/bat ~/.config/bat


mkdir -p ~/.cache/awesome
mkdir -p ~/.config/

ln -s ~/.dotfiles/awesome ~/.config/
