#!/usr/bin/env bash

BASE=$(pwd)

mkdir -pv bak

# Symlink .config directories (and backup existing)
mkdir -p ~/.config
for entry in "$BASE"/config/*/
do
	dir_name=$(basename "$entry")
	dir_path=~/.config/$dir_name
	if [ -e "$dir_path" ] && [ ! -L "$dir_path" ]; then
		echo "backing up existing $dir_path"
		mv -v "$dir_path" bak/
	fi
	echo "symlinking $dir_path -> $BASE/config/$dir_name"
	ln -sfn "$BASE/config/$dir_name" "$dir_path"
done


# Symlink ~/.claude/settings.json
mkdir -p ~/.claude
if [ -e ~/.claude/settings.json ] && [ ! -L ~/.claude/settings.json ]; then
	echo "backing up existing ~/.claude/settings.json"
	mv -v ~/.claude/settings.json bak/
fi
echo "symlinking ~/.claude/settings.json -> $BASE/claude/settings.json"
ln -sfn "$BASE/claude/settings.json" ~/.claude/settings.json

# Symlink all files folders (and backup existing)
for rc in *rc *profile *ignore; do
	target_location=~/.$rc
	[ -e ~/.$rc ] && echo "backing up existing $target_location" && mv -v $target_location bak/.$rc
	echo "symlinking $target_location -> $BASE/$rc"
	ln -sfv $BASE/$rc $target_location
done

# Dynamically create bashrc
echo "creating .bashrc from template"
# cp $BASE/template/bashrc ~/.bashrc
sed -e "s|__REPLACE__|$BASE|g" $BASE/bashrc_template > ~/.bashrc
chmod +x ~/.bashrc
chmod 600 ~/.bashrc

# download some helpers
mkdir -pv ~/.bin

# git-prompt
if [ ! -e ~/.bin/git-prompt.sh ]; then
	echo "downloading ~/.bin/git-prompt.sh"
	curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -o ~/.bin/git-prompt.sh
fi
# z.sh
if [ ! -e ~/.bin/z.sh ]; then
	echo "downloading ~/.bin/z.sh"
	curl https://raw.githubusercontent.com/rupa/z/master/z.sh -o ~/.bin/z.sh
fi

read -p 'Git User Name (empty to skip): ' gitname

if [ ! -z "$gitname" ]
then
	read -p 'Git User Email: ' gitemail
	git config --global user.email $gitemail
	git config --global user.name "$gitname"
	echo "Configured to use git as $gitname <$gitemail>"
fi

git config --global core.excludesfile ~/.gitignore

# Check if some base tools are installed and prompt to install otherwise
command -v rg >/dev/null 2>&1 || { echo >&2 "rg (ripgrep) is needed but not found as executable in $PATH, please install."; }
command -v fzf >/dev/null 2>&1 || { echo >&2 "fzf is needed but not found as executable in $PATH, please install."; }
