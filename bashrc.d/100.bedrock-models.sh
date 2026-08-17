# Load canonical model IDs and AWS Bedrock config.
# Sourced here so the shell (and any subprocess like `claude`) inherits the vars.
# The single source of truth is config/bedrock.env in dotfiles.
_DOTFILES="${DOTFILES_DIR:-$HOME/Code/dotfiles}"
if [ -f "$_DOTFILES/config/bedrock.env" ]; then
  # shellcheck source=/dev/null
  source "$_DOTFILES/config/bedrock.env"
  # Expose as the env var names Claude Code and the AWS CLI expect.
  export ANTHROPIC_DEFAULT_OPUS_MODEL="$BEDROCK_OPUS_MODEL"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="$BEDROCK_SONNET_MODEL"
fi
unset _DOTFILES
