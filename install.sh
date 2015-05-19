#!/usr/bin/env bash

# Symlink all files and folders
ln -s $(pwd)/.vimrc ${HOME}/.vimrc
ln -s $(pwd)/.vim ${HOME}/.vim
ln -s $(pwd)/.agignore ${HOME}/.agignore
ln -s $(pwd)/.tmux.conf ${HOME}/.tmux.conf

# Install vim-plug and all plugins
if [ ! -e $HOME/.vim/autoload/plug.vim ]; then
	curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim -u $HOME/.vimrc +PlugInstall +PlugClean! +qa
