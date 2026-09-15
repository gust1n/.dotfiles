#!/usr/bin/env bash
# Set this machine up. Everything is declared in config/mise/config.toml; this
# script only records where the repo is, then hands over.
#
#   curl https://mise.run | sh
#   git clone <repo> <anywhere>
#   <anywhere>/install.sh
#
# Re-running is safe: every phase converges.
set -euo pipefail

# Where this checkout actually lives. Nothing in the repo hardcodes it.
BASE="$(cd "$(dirname "$0")" && pwd)"

if ! command -v mise >/dev/null 2>&1; then
	echo >&2 "mise is not installed — run 'curl https://mise.run | sh' first."
	exit 1
fi

# Clone this repo wherever you like. ~/.dotfiles is not where it has to live — it
# is a pointer TO wherever it lives, computed above from $0. It exists because
# mise's [dotfiles] sources cannot be templated, so they need one stable prefix
# to hang off; `~/.dotfiles/bashrc` resolves correctly from any checkout path.
#
#   ~/.dotfiles     → this checkout (whatever path that is)
#   ~/.config/mise  → the config dir, reached through ~/.dotfiles, so moving the
#                     checkout means re-pointing one symlink and nothing else.
link() {
	local target=$1 source=$2
	if [ -e "$target" ] && [ ! -L "$target" ]; then
		mkdir -p "$BASE/bak"
		mv -v "$target" "$BASE/bak/"
	fi
	ln -sfn "$source" "$target"
}

mkdir -p ~/.config
link ~/.dotfiles "$BASE"
link ~/.config/mise ~/.dotfiles/config/mise

mise trust ~/.config/mise/config.toml
mise bootstrap --yes

# The login shell lives in config.macos.toml, which loads only under -E macos.
# It runs last on purpose: chsh may prompt, and a failure here must not stop the
# phases above, which it would if it ran inside `mise bootstrap`.
if [ "$(uname -s)" = "Darwin" ]; then
	mise bootstrap user apply -E macos --yes ||
		echo >&2 "could not set the login shell; run: chsh -s /opt/homebrew/bin/bash"
fi

# ~/.gitconfig stays unmanaged: `gh auth login` writes machine-specific absolute
# paths into it, which have no business in the repo.
git config --global core.excludesfile ~/.gitignore
git config --global user.name >/dev/null 2>&1 ||
	echo >&2 "set your git identity: git config --global user.name '…' && git config --global user.email '…'"

if ! command -v agy >/dev/null 2>&1; then
	echo "Installing Antigravity CLI (agy) — self-updating, not in the mise registry."
	curl -fsSL https://antigravity.google/cli/install.sh | bash
fi

echo
echo "Done. ~/.dotfiles -> $BASE"
echo "Open a new shell."
