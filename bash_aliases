# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='exa -abghHliS --git'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias ber='bundle exec rspec -c'

alias rrn="rustup run nightly"

alias mutt='MUTT_PROFILE=gmail /usr/bin/mutt'
alias mutt-work='MUTT_PROFILE=work /usr/bin/mutt'

alias s='TERM=screen-256color'


alias ssl1='PKG_CONFIG_PATH=/usr/lib/openssl-1.0/pkgconfig CFLAGS+=" -I/usr/include/openssl-1.0" LDFLAGS+=" -L/usr/lib/openssl-1.0 -lssl"'

alias vim='env -u GEM_PATH -u GEM_HOME \vim'
alias gvim='env -u GEM_PATH -u GEM_HOME \gvim'
alias svim='vim -u ~/.vim/simple_vimrc'
alias sgvim='gvim -u ~/.vim/simple_vimrc'

alias dc='docker-compose'
alias dcr='docker-compose run --rm app'
