setxkbmap -layout pl
if [ -f $HOME/.Xmodmap ]; then
    /usr/bin/xmodmap $HOME/.Xmodmap
fi

export QT_QPA_PLATFORMTHEME="qt5ct"

source ~/.dotfiles/xinitrc.local

exec /usr/bin/awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr
