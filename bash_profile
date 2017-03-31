#
# ~/.bash_profile
#
# export TERM=xterm-256color

export PATH="{$HOME}/.rvm/bin:${PATH}"
export PATH="${PATH}:${HOME}/bin"
export PATH="${PATH}:${HOME}/.cargo/bin"
export PATH="${PATH}:${HOME}/.node_modules/bin"

[[ -f ~/.bashrc ]] && . ~/.bashrc
