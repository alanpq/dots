
## PNPM
export PNPM_HOME="$HOME/.local/share/pnpm/"
source /usr/share/nvm/init-nvm.sh
## END PNPM

## PATH
export GO_ROOT="$HOME/go"

export PATH="$HOME/.cargo/bin/:$PATH"
export PATH="$GO_ROOT/bin/:$PATH"

## END PATH

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' verbose true

setopt autocd extendedglob nomatch
unsetopt beep notify
bindkey -e

bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

bindkey "^[[3~" delete-char # delete
bindkey "^[[3;5~" kill-word # ctrl + delete

# ALIASES

alias sudo='nocorrect sudo -E '
alias vim='nvim'

alias g='git'
alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gp='git push'

alias icat='kitty +kitten icat'

alias ls="exa"
alias ll="ls -l"
alias la="ls -la"

alias ssh="TERM=xterm-kitty ssh"

# END ALIASES

# source antidote
source '/usr/share/zsh-antidote/antidote.zsh'
#source ${ZDOTDIR:-~}/.antidote/antidote.zsh


## PLUGIN CONFIG
# you-should-use hardcore mode
export YSU_HARDCORE=1

# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load

eval "$(starship init zsh)"
