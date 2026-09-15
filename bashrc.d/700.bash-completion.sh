# bash-completion@2 is installed by mise (see [bootstrap.packages]), which pours
# bottles into the Homebrew prefix without needing the brew binary — so find the
# prefix by path, not by asking brew.
if [ -z "$HOMEBREW_PREFIX" ]; then
  for PREFIX in /opt/homebrew /home/linuxbrew/.linuxbrew; do
    [ -d "$PREFIX" ] && HOMEBREW_PREFIX="$PREFIX" && break
  done
fi

if [ -z "$HOMEBREW_PREFIX" ]; then
  [ -f /etc/bash_completion ] && source /etc/bash_completion
elif [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
  source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
elif [ -d "${HOMEBREW_PREFIX}/etc/bash_completion.d" ]; then
  for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
    [[ -r "$COMPLETION" ]] && source "$COMPLETION"
  done
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi
