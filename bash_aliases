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
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias ber='bundle exec rspec -c'

alias rrn="rustup run nightly"

alias mutt='MUTT_PROFILE=gmail /usr/bin/mutt'
alias mutt-work='MUTT_PROFILE=work /usr/bin/mutt'

alias s='TERM=screen-256color'

alias vim='vim'
alias svim='vim -u ~/.vim/simple_vimrc'
alias sgvim='gvim -u ~/.vim/simple_vimrc'

alias web='cd ~/dev/icls/hg/web'
alias ep='cd ~/dev/icls/hg/event_processor'
alias te='cd ~/dev/icls/hg/transaction_endpoint'
alias ssp='cd ~/dev/icls/hg/self_service'

alias db1='mysql -u matraszek_j -phLKmZkLn7b -h q-icls-db01.wirecard.sys coupon'
alias qadump='mysqldump -u matraszek_j -phLKmZkLn7b -h q-icls-db01.wirecard.sys --compress --verbose --lock-tables=false coupon'
alias ssl1='PKG_CONFIG_PATH=/usr/lib/openssl-1.0/pkgconfig CFLAGS+=" -I/usr/include/openssl-1.0" LDFLAGS+=" -L/usr/lib/openssl-1.0 -lssl"'
