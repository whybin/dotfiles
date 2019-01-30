export PATH=/usr/local/bin:$HOME/bin:$PATH
export PATH=.vim/execs:$PATH
export PATH=$HOME/Library/Haskell/bin:$PATH
export PATH=$HOME/.rvm/bin:$PATH

export TERM=xterm-256color

export HISTFILE=~/.zsh_history
export SAVEHIST=10000
export HISTSIZE=10000

# My custom theme https://gitlab.com/waymark/on-the-lambda
source ~/.zsh/on-the-lambda.zsh-theme

alias node="rlwrap -a -- node"  # Use readline to access vi-mode key bindings

plugins=(git)

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

# Fuzzy finder & reverse-i-search
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
