if [ -f ~/.dotfiles/xinitrc.local ]; then
	. ~/.dotfiles/xinitrc.local
fi

# Source xprofile for startx compatibility
[ -f ~/.xprofile ] && . ~/.xprofile

# Load Xresources (ly's setup.sh does this automatically, but needed for startx)
[ -f ~/.Xresources ] && xrdb ~/.Xresources

# Import DISPLAY and XAUTHORITY into systemd user environment
# This is required for xdg-desktop-portal (used by Electron apps for file pickers)
# when using SLiM or startx, which don't do this automatically
systemctl --user import-environment DISPLAY XAUTHORITY

exec /usr/sbin/awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr

# vim: set ft=sh:
