if [ -f ~/.dotfiles/xinitrc.local ]; then
	. ~/.dotfiles/xinitrc.local
fi

xrdb ~/.dotfiles/Xresources.local

bash ~/.screenlayout/a.sh

# Import DISPLAY and XAUTHORITY into systemd user environment
# This is required for xdg-desktop-portal (used by Electron apps for file pickers)
# when using SLiM or startx, which don't do this automatically
systemctl --user import-environment DISPLAY XAUTHORITY

exec /usr/bin/awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr

# vim: set ft=sh:
