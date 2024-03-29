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
ln -s ~/.dotfiles/mostrc ~/.mostrc
ln -s ~/.dotfiles/gpg-agent.conf ~/.gnupg/gpg-agent.conf
ln -s ~/.dotfiles/ctags.d ~/.ctags.d


mkdir -p ~/.cache/awesome
ln -s ~/.dotfiles/awesome ~/.config/
