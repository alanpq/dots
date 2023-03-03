# PATH
PATH="$HOME/bin:$PATH"

if hash ruby 2>/dev/null ; then
  PATH="$PATH:$(ruby -e 'puts Gem.user_dir')/bin"
fi

if hash yarn 2>/dev/null ; then
  PATH="$PATH:${HOME}/.yarn/bin"
fi

[ -d $HOME/.emacs.d/bin ] && PATH="$HOME/.emacs.d/bin:$PATH"

export PATH

export TERMINAL=xst
export TERM=xst-256color

# GPG
export GPG_TTY=$(tty)
export GPG_AGENT_INFO=""

# Editor
export VISUAL=vim
export EDITOR=nvim
export SUDO_EDITOR=nvim

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Hacking Tools
export HYDRA_PROXY_HTTP="$HTTP_PROXY"
