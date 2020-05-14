if [ -f ~/.dotfiles/xinitrc.local ]; then
	. ~/.dotfiles/xinitrc.local
fi

exec /usr/bin/awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr

# vim: set ft=sh:
