if command -v git >/dev/null; then
  alias gst='git status'
  alias gc='git commit'
  alias gco='git checkout'
  alias ga='git add'
  alias gd='git diff'

  gbr() {
    local branches branch
    branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
    branch=$(echo "$branches" |
             fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  }
fi
