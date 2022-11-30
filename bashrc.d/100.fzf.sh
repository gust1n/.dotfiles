if [ -f ~/.fzf.bash ]; then
	source ~/.fzf.bash
else
	[ -f /usr/share/fzf/key-bindings.bash ] && source /usr/share/fzf/key-bindings.bash
	[ -f /usr/share/fzf/completion.bash ] && source /usr/share/fzf/completion.bash
fi

export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_DEFAULT_OPTS='--bind J:down,K:up --reverse '
