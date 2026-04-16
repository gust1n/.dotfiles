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

### jj/git prompt function
# Detect if we're in a jj or git repo (jj takes priority)
__jjgit_prompt() {
    local D="/$PWD"
    # Walk up directory tree to find .jj or .git
    while test -n "$D"; do
        if test -e "$D/.jj"; then
            # jj repo: use jj log to get status
            # --ignore-working-copy: avoid snapshotting which could create divergent commits
            jj --ignore-working-copy --no-pager log --no-graph --color=always -r @ -T \
                'separate(" ", format_short_change_id_with_change_offset(self), format_short_commit_id(commit_id), bookmarks, if(conflict, label("conflict", "conflict")), if(empty, label("empty", "(empty)")), if(description, description.first_line(), label("description placeholder", "(no description set)")))' 2>/dev/null
            return
        fi
        if test -e "$D/.git"; then
            # git repo: use existing __git_ps1 if available
            if type __git_ps1 &>/dev/null; then
                __git_ps1 "%s"
            fi
            return
        fi
        D="${D%/*}"
    done
}

# Source git-prompt.sh if available (for __git_ps1 function)
if [ -e ~/.bin/git-prompt.sh ]; then
    source ~/.bin/git-prompt.sh
    export GIT_PS1_SHOWDIRTYSTATE=1
fi

### Actual prompt
# Set the terminal title to the current working directory.
PS1="\[\033]0;\w\007\]";
PS1+="\[${bold}\]\n"; # newline
PS1+="\[${userStyle}\]\u"; # username
PS1+="\[${white}\] at ";
PS1+="\[${hostStyle}\]\h"; # host
PS1+="\[${white}\] in ";
PS1+="\[${green}\]\w"; # working directory
PS1+="\[${white}\] on \[${violet}\](\$(__jjgit_prompt))"; # jj/git repository details
PS1+="\n";
PS1+="\\[${white}\]\$(date +%H:%M) $ \[${reset}\]"; # `$` (and reset color)
export PS1;

PS2="\[${yellow}\]→ \[${reset}\]";
export PS2;
