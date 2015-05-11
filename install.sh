#!/usr/bin/env bash

# Symlink all files and folders
ln -s $(pwd)/.vimrc ${HOME}/.vimrc
ln -s $(pwd)/.vim ${HOME}/.vim

# Install Vundle (for installing the rest of the vim plugins)
git clone https://github.com/gmarik/Vundle.vim.git ${HOME}/.vim/bundle/Vundle.vim
