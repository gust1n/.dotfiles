if command -v fzf >/dev/null; then
	eval "$(fzf --bash)"
fi

# Use fd for better file finding (respects .gitignore, excludes .git)
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--bind J:down,K:up --reverse'

# CTRL-T: file finder with bat preview
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# ALT-C: directory navigator
export FZF_ALT_C_COMMAND="fd --type d --strip-cwd-prefix --hidden --follow --exclude .git"
