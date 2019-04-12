#
# ~/.bash_profile
#
# export TERM=xterm-256color

export PATH="{$HOME}/.rvm/bin:${PATH}"
export PATH="${PATH}:${HOME}/bin"
export PATH="${PATH}:${HOME}/.cargo/bin"
export PATH="${PATH}:${HOME}/.ghcup/bin"

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
