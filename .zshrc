export PATH=/usr/local/bin:$HOME/bin:.vim/execs:$PATH
export ZSH=~/.oh-my-zsh
export TERM=xterm-256color

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="agnoster"

alias node="rlwrap -a -- node"  # Use readline to access vi-mode key bindings

plugins=(git)

source $ZSH/oh-my-zsh.sh

bindkey -v # Edit commands in vi-mode
bindkey 'jk' vi-cmd-mode

PS1+='${VIMODE}'
function zle-line-init zle-keymap-select {
    NORMAL='%B%F{green}N>%f%b'
    VIMODE="${${KEYMAP/vicmd/$NORMAL}/(main|viins)/}"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

# OPAM configuration
. ~/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
