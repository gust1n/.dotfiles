if command -v go >/dev/null; then
	eval "$(fzf --bash)"
fi

export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_DEFAULT_OPTS='--bind J:down,K:up --reverse '
