#!/usr/bin/env bash

BASE=$(pwd)

# File to put all system specific stuff in
touch bashrc-extra

# Symlink all files folders (and backup existing)
mkdir -pv bak
for rc in *rc *profile tmux.conf agignore; do
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
	brew install \
		ag bash-completion bash-git-prompt composer cscope ctags \
		git go mysql redis tmux vim wget
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
