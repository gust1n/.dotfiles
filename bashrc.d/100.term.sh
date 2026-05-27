export TERM=screen-256color

# Source Ghostty shell integration (defines __ghostty_hook used in PROMPT_COMMAND)
if [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]]; then
  source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash" 2>/dev/null || true
fi
