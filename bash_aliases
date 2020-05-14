# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias la='exa -abghHliS --git'
alias ll='exa -bghHliS --git'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias ber='bundle exec rspec -c'

alias rrn="rustup run nightly"

alias mutt='MUTT_PROFILE=gmail /usr/bin/neomutt'
alias mutt-work='MUTT_PROFILE=work /usr/bin/neomutt'

alias s='TERM=screen-256color'

alias vim='env -u GEM_PATH -u GEM_HOME \vim'
alias gvim='env -u GEM_PATH -u GEM_HOME \gvim'
alias svim='vim -u ~/.vim/simple_vimrc'
alias sgvim='gvim -u ~/.vim/simple_vimrc'

alias dc='docker-compose'
alias dcr='docker-compose run --rm app'
alias dcrbe='docker-compose run --rm backend bundle exec'
alias dcr-sp='docker-compose run --service-ports --rm app'

alias k='kubectl'
complete -F _complete_alias k
alias kc='kubectx'
complete -F _complete_alias kc
alias kn='kubens'
complete -F _complete_alias kn

function gsed () {
  if [ -z "$3" ]
  then
    echo "== Usage:    gsed search_string replace_string [path]"
  else
    egrep --exclude-dir=.git -lRZ "$1" $3 | xargs -0 -l sed -i -e "s/$1/$2/g"
  fi
}

nnn ()
{
    # Block nesting of nnn in subshells
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi

    # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
    # To cd on quit only on ^G, remove the "export" as in:
    NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    # export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    EDITOR="tewrap"
    LC_COLLATE="C"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    command nnn -e "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}

# vim: set ft=sh:
