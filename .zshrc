export PATH=/usr/local/bin:$HOME/bin:$PATH
export PATH=$HOME/Library/Haskell/bin:$PATH
export PATH=$HOME/.rvm/bin:$PATH

export TERM=xterm-256color

export HISTFILE=~/.zsh_history
# Number of commands to save
export SAVEHIST=10000
# Number to search from
export HISTSIZE=10000
setopt hist_ignore_all_dups

autoload -U compinit
compinit
# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# Immediately insert first match
setopt MENU_COMPLETE

# Colorize `ls`
if [[ $OSTYPE =~ 'darwin' ]]; then
    alias ls='ls -G'
elif [[ $OSTYPE == 'linux-gnu' ]]; then
    alias ls='ls --color=auto'
fi

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
