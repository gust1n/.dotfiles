if command -v go >/dev/null; then
	PATH+=":/usr/local/go/bin"
	PATH+=":$HOME/go/bin"
fi
