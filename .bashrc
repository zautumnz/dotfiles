# shellcheck shell=bash

# if not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# little helper
_sourceif() {
    [ -f "$1" ] && . "$1"
}

_sourceif "$HOME/.bash/bashrc.sh"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
