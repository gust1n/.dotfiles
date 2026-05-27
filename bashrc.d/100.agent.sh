# Add dotfiles bin to PATH for agent scripts
PATH+=":$HOME/Code/dotfiles/bin"

# Completion for agent subcommands
_agent_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "new ls switch kill send capture tidy jump-next help" -- "$cur") )
}
complete -F _agent_completions agent
