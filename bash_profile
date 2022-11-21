# Load the shell dotfile
. ~/.bashrc

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Share bash history between sessions
export HISTCONTROL=ignoredups:erasedups;  # no duplicate entries
export HISTSIZE=100000;                   # big big history
export HISTFILESIZE=100000;               # big big history
shopt -s histappend;                      # append to history, don't overwrite it
# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND";


# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null;
done;

# Add tab completion for many Bash commands
if command -v brew &> /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
	source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
	source /etc/bash_completion;
fi;
