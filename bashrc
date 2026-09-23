# Interactive bash setup. Copied to ~/.bashrc by `mise bootstrap`.
#
# Environment variables, PATH and aliases are NOT here — they live in
# config/mise/config.toml under [env] and [shell_alias], so they layer per
# machine and per profile. Only what mise cannot express belongs in this file:
# shell functions, `eval` integrations, completions and the prompt.

# PROMPT_COMMAND is per-shell state. An inherited value would make every nested
# shell append its hooks again, so each shell starts empty and builds its own.
unset PROMPT_COMMAND

# Opt this machine into tracked profiles, e.g. `echo work > ~/.mise-env` to load
# config.work.toml. Must precede activation, which is why it is not in
# ~/.bashrc.local at the bottom.
[ -f ~/.mise-env ] && export MISE_ENV="$(tr -d '[:space:]' <~/.mise-env)"

# mise first: everything below needs the tools it puts on PATH.
if command -v mise >/dev/null; then
	eval "$(mise activate bash)"
fi

# System-wide bashrc.
[ -f /etc/bashrc ] && . /etc/bashrc

# Ghostty shell integration defines __ghostty_hook, used in PROMPT_COMMAND.
if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
	source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash" 2>/dev/null || true
fi

### Integrations

# bash-completion@2 comes from [bootstrap.packages]. mise pours bottles into the
# Homebrew prefix without needing the brew binary, so find the prefix by path.
if [ -z "$HOMEBREW_PREFIX" ]; then
	for PREFIX in /opt/homebrew /home/linuxbrew/.linuxbrew; do
		[ -d "$PREFIX" ] && HOMEBREW_PREFIX="$PREFIX" && break
	done
fi
if [ -r "${HOMEBREW_PREFIX:-/nonexistent}/etc/profile.d/bash_completion.sh" ]; then
	source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion
fi

command -v fzf >/dev/null && eval "$(fzf --bash)"
command -v herdr >/dev/null && eval "$(herdr completion bash 2>/dev/null)"

_herdr_jj_completions() {
	local cur="${COMP_WORDS[COMP_CWORD]}" prev="${COMP_WORDS[COMP_CWORD - 1]}"
	case "$prev" in
	--repo)
		COMPREPLY=($(compgen -d -- "$cur"))
		return
		;;
	--model)
		COMPREPLY=($(compgen -W "opus sonnet flash" -- "$cur"))
		return
		;;
	--name | --prompt | --agent)
		COMPREPLY=()
		return
		;;
	esac
	if [[ "$cur" == -* ]]; then
		COMPREPLY=($(compgen -W "--repo --name --prompt --model --agent" -- "$cur"))
	else
		COMPREPLY=($(compgen -W "new rm tidy help" -- "$cur"))
	fi
}
complete -F _herdr_jj_completions herdr-jj

### Shell options and history
#
# These are interactive-shell settings, so they belong here and not in
# bash_profile: a non-login interactive bash must get them too. None are
# exported — they configure this shell, not its children.

shopt -s histappend # append to the history file, never clobber it
shopt -s cdspell    # autocorrect typos in cd paths
shopt -s autocd     # `foo/bar` means `cd foo/bar`
shopt -s globstar   # `**` recurses
shopt -s nocaseglob # case-insensitive globbing

HISTSIZE=100000
HISTFILESIZE=1000000                 # larger than HISTSIZE, so exits never truncate
HISTCONTROL=ignorespace:ignoredups   # leading space keeps a command out entirely
HISTTIMEFORMAT='%F %T '              # safe with fzf: its Ctrl-R reads `fc -ln`

# -a flushes this session's new commands; -n reads back only what other sessions
# have appended since the last read, so up-arrow order stays stable per
# terminal. The file is only appended to, so `erasedups` would have no effect.
PROMPT_COMMAND="history -a; history -n${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

### Functions

# Attach to a tmux session by name, or pick one with fzf.
tm() {
	[[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
	if [ "$1" ]; then
		tmux "$change" -t "$1" 2>/dev/null || (tmux new-session -d -s "$1" && tmux "$change" -t "$1")
		return
	fi
	session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&
		tmux "$change" -t "$session" || echo "No sessions found."
}

### Prompt

reset="\e[0m"
green="\e[1;32m"
red="\e[1;31m"
violet="\e[1;35m"
white="\e[1;37m"
yellow="\e[1;33m"

# Highlight the user name as root, and the hostname over SSH.
[[ "${USER}" == "root" ]] && userStyle="${red}" || userStyle="${yellow}"
[[ "${SSH_TTY}" ]] && hostStyle="${red}" || hostStyle="${yellow}"

# Repository status for the prompt. jj wins over git when both are present.
__jjgit_prompt() {
	local D="/$PWD"
	while test -n "$D"; do
		if test -e "$D/.jj"; then
			# --ignore-working-copy: never snapshot from the prompt, which could
			# create divergent commits.
			jj --ignore-working-copy --no-pager log --no-graph --color=always -r @ -T \
				'separate(" ", format_short_change_id_with_change_offset(self), format_short_commit_id(commit_id), bookmarks, if(conflict, label("conflict", "conflict")), if(empty, label("empty", "(empty)")), if(description, description.first_line(), label("description placeholder", "(no description set)")))' 2>/dev/null
			return
		fi
		if test -e "$D/.git"; then
			local branch
			branch=$(git branch --show-current 2>/dev/null) || return
			git diff --quiet --ignore-submodules HEAD 2>/dev/null || branch+="*"
			printf '%s' "$branch"
			return
		fi
		D="${D%/*}"
	done
}

PS1="\[\033]0;\w\007\]"                                  # terminal title
PS1+="\n"
PS1+="\[${userStyle}\]\u"                                # user
PS1+="\[${white}\] at "
PS1+="\[${hostStyle}\]\h"                                # host
PS1+="\[${white}\] in "
PS1+="\[${green}\]\w"                                    # working directory
PS1+="\[${white}\] on \[${violet}\](\$(__jjgit_prompt))" # repo details
PS1+="\n"
PS1+="\[${white}\]\$(date +%H:%M) $ \[${reset}\]"

PS2="\[${yellow}\]→ \[${reset}\]"

# Machine-specific shell additions that mise cannot express. Gitignored.
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
