# Login shell setup. Symlinked to ~/.bash_profile by `mise bootstrap`.
#
# Nothing lives here. Login shells do not read ~/.bashrc on their own, so this
# file exists only to source it — that way login and non-login interactive shells
# are configured identically. Shell options and history moved into bashrc for the
# same reason.

. ~/.bashrc
