# System default
# --------------------------------------------------------------------

export PLATFORM=$(uname -s)
[ -f /etc/bashrc ] && . /etc/bashrc

BASE=$(dirname $(readlink $BASH_SOURCE))

# Prompt
# --------------------------------------------------------------------
### Colors / font style
bold='';
reset="\e[0m";
black="\e[1;30m";
blue="\e[1;34m";
cyan="\e[1;36m";
green="\e[1;32m";
orange="\e[1;33m";
purple="\e[1;35m";
red="\e[1;31m";
violet="\e[1;35m";
white="\e[1;37m";
yellow="\e[1;33m";

### States
# Highlight the user name when logged in as root.
if [[ "${USER}" == "root" ]]; then
	userStyle="${red}";
else
	userStyle="${orange}";
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
	hostStyle="${bold}${red}";
else
	hostStyle="${yellow}";
fi;

### Actual prompt
# Set the terminal title to the current working directory.
PS1="\[\033]0;\w\007\]";
PS1+="\[${bold}\]\n"; # newline
PS1+="\[${userStyle}\]\u"; # username
PS1+="\[${white}\] at ";
PS1+="\[${hostStyle}\]\h"; # host
PS1+="\[${white}\] in ";
PS1+="\[${green}\]\w"; # working directory
if [ -e ~/.git-prompt.sh ]; then
	source ~/.git-prompt.sh
	export GIT_PS1_SHOWDIRTYSTATE=1
	PS1+='$(__git_ps1 "${white} on ${violet}(%s)")'; # Git repository details
fi
PS1+="\n";
PS1+="\[${white}\]\$ \[${reset}\]"; # `$` (and reset color)
export PS1;

PS2="\[${yellow}\]→ \[${reset}\]";
export PS2;

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
alias cd...='cd ../..'
alias cd....='cd ../../..'
alias cd.....='cd ../../../..'
alias cd......='cd ../../../../..'

### git
alias gst='git status'
alias gc='git commit'
alias ga='git add'
alias gd='git diff'

### Colored ls
if [ -x /usr/bin/dircolors ]; then
	eval "`dircolors -b`"
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
elif [ "$PLATFORM" = Darwin ]; then
	alias ls='ls -G'
fi

EXTRA=$BASE/bashrc-extra
[ -f "$EXTRA" ] && source "$EXTRA"

# fzf (https://github.com/junegunn/fzf)
# --------------------------------------------------------------------
if [ -n "$TMUX_PANE" ]; then
	fzf_tmux_helper() {
		local sz=$1;  shift
		local cmd=$1; shift
		tmux split-window $sz \
			"bash -c \"\$(tmux send-keys -t $TMUX_PANE \"\$(source ~/.fzf.bash; $cmd)\" $*)\""
	}

	# https://github.com/wellle/tmux-complete.vim
	fzf_tmux_words() {
		fzf_tmux_helper \
			'-p 40' \
			'~/.vim/plugged/tmux-complete.vim/sh/tmuxcomplete | fzf --multi | paste -sd" " -'
	}

	# Bind CTRL-X-CTRL-T to tmuxcomplete
	bind '"\C-x\C-t": "$(fzf_tmux_words)\e\C-e"'
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
