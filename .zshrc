eval "$(dircolors)"

export PATH=$PATH:/home/gamer/.gem/ruby/2.7.0/bin
export PATH=$PATH:/home/gamer/scripts/
export PATH=$PATH:/home/gamer/.script/
export PATH=$PATH:/home/gamer/Android/Sdk/ndk/21.0.6113669/
export ANDROID_SDK_ROOT="/home/gamer/Android/Sdk/"
export NDK_ROOT="/home/gamer/Android/Sdk/ndk/21.0.6113669"
export ANDROID_NDK_HOME="/home/gamer/Android/Sdk/ndk/21.0.6113669"

#=========================== GEOMETRY CONFIG ======================================
#-general
GEOMETRY_SEPARATOR=" "    # use ' ' to separate function output

#-geometry_status
GEOMETRY_STATUS_SYMBOL="[] "             # default prompt symbol
GEOMETRY_STATUS_SYMBOL_ERROR="[!] "       # displayed when exit value is != 0
GEOMETRY_STATUS_COLOR_ERROR="magenta"  # prompt symbol color when exit value is != 0
GEOMETRY_STATUS_COLOR="orange"        # prompt symbol color
GEOMETRY_STATUS_COLOR_ROOT="red"       # root prompt symbol color

#-geometry-exitcode
GEOMETRY_EXITCODE_COLOR="red" # exit code color

#-geometry-git
GEOMETRY_GIT_SYMBOL_REBASE="\uE0A0" # set the default rebase symbol to the powerline symbol 
GEOMETRY_GIT_SYMBOL_STASHES=x       # change the git stash indicator to `x`
GEOMETRY_GIT_COLOR_STASHES=blue     # change the git stash color to blue
GEOMETRY_GIT_GREP=ack               # define which grep-like tool to use (By default it looks for rg, ag and finally grep)
GEOMETRY_GIT_NO_COMMITS_MESSAGE=""  # hide the 'no commits' message in new repositories
GEOMETRY_GIT_TIME_DETAILED=true     # show full time (e.g. `12h 30m 53s`) instead of the coarsest interval (e.g. `12h`)


# == prompt overrides
# GEOMETRY_PROMPT=(geometry_status geometry_path) # redefine left prompt
GEOMETRY_RPROMPT+=(geometry_exec_time pwd)      # append exec_time and pwd right prompt
#==================================================================================


# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory autocd extendedglob
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall

zstyle ':completion:*' auto-description '%d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/gamer/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
bindkey "^[[3~" delete-char
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
#alias
alias vim='nvim'

alias g='git'
alias cfgs='nvim ~/.zshrc ~/.zsh_plugins.txt ~/.config/nvim/init.vim'
alias ll='ls -l'
alias la='ls -a'
alias lg='ls --group-directories-first'

alias ls='ls --color'
alias dir='dir --color'



source /home/gamer/.zsh_plugins.sh
