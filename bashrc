# Options
# --------------------------------------------------------------------
if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi

# Environment variables
# --------------------------------------------------------------------
### Global
export GOPATH=~/go
if [ -z "$PATH_EXPANDED" ]; then
	export PATH=/usr/local/bin:$GOPATH/bin:$PATH
	export PATH_EXPANDED=1
fi
export EDITOR=vim
export LANG=en_US.UTF-8

### OS X
COPYFILE_DISABLE=1; export COPYFILE_DISABLE # turn off special handling of ._* files in tar, etc.

# Aliases
# --------------------------------------------------------------------
alias cd ...='cd ../..'
alias cd ....='cd ../../..'
alias cd .....='cd ../../../..'
alias cd ......='cd ../../../../..'

alias gs='git status'
alias gc='git commit'
alias ga='git add'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
