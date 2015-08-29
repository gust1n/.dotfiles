#!/usr/bin/env bash

BASE=$(pwd)

# File to put all system specific stuff in
touch bashrc-extra

# Symlink all files folders (and backup existing)
mkdir -pv bak
for rc in *rc *profile tmux.conf agignore gitignore; do
	[ -e ~/.$rc ] && mv -v ~/.$rc bak/.$rc
	ln -sfv $BASE/$rc ~/.$rc
done

# git-prompt
if [ ! -e ~/.git-prompt.sh ]; then
	curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.git-prompt.sh
fi

if [ $(uname -s) = 'Darwin' ]; then
	# Homebrew
	[ -z "$(which brew)" ] &&
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	echo "Updating homebrew"
	brew update
	# Install GNU core utilities (those that come with OS X are outdated).
	# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`
	# (unless installed --with-default-names).
	brew install coreutils --with-default-names
	# Install GNU `sed`, overwriting the built-in `sed`.
	brew install gnu-sed --with-default-names
	# Install Bash 4.
	# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
	# running `chsh`.
	brew install bash
	brew tap homebrew/versions
	brew install bash-completion2

	# Install `wget` with IRI support.
	brew install wget --with-iri

	# Install more recent versions of some OS X tools.
	brew install vim --override-system-vi
	brew install homebrew/dupes/grep
	brew install homebrew/dupes/openssh

	# Useful tools
	brew install ag
	brew install composer
	brew install cscope
	brew install ctags
	brew install git
	brew install go
	brew install mysql
	brew install redis
	brew install tmux
	brew install ssh-copy-id

	# Remove outdated versions from the cellar.
	brew cleanup
fi

git config --global user.email "jocke.gustin@gmail.com"
git config --global user.name "Jocke Gustin"

tmux source-file ~/.tmux.conf

# Install vim-plug and all plugins
if [ ! -e ~/.vim/autoload/plug.vim ]; then
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -u ~/.vimrc +PlugInstall +PlugClean! +qa
