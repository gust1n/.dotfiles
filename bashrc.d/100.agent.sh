# Add dotfiles bin to PATH for agent scripts
PATH+=":$HOME/Code/dotfiles/bin"

# Completion for herdr-jj subcommands
_herdr_jj_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}" prev="${COMP_WORDS[COMP_CWORD-1]}"
  case "$prev" in
    --repo) COMPREPLY=( $(compgen -d -- "$cur") ); return ;;
    --name|--prompt|--agent) COMPREPLY=(); return ;;
  esac
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "--repo --name --prompt --agent" -- "$cur") )
  else
    COMPREPLY=( $(compgen -W "new rm tidy help" -- "$cur") )
  fi
}
complete -F _herdr_jj_completions herdr-jj

# herdr ships its own completions
command -v herdr >/dev/null && eval "$(herdr completion bash 2>/dev/null)"
