# dotfiles

Personal dotfiles of gust1n. macOS, bash, neovim, jj.

Everything the machine needs is declared in one file, `config/mise/config.toml` —
tools, system packages, environment, shell aliases, the symlinks into `$HOME`, and
the tmux plugin checkouts. `mise bootstrap` applies it, and every step converges, so
running it again is a no-op.

## Bootstrap

```bash
curl https://mise.run | sh
git clone https://github.com/gust1n/.dotfiles ~/Code/dotfiles
~/Code/dotfiles/install.sh
```

`install.sh` symlinks `~/.dotfiles` to the checkout and `~/.config/mise` to
`config/mise`, then hands over to `mise bootstrap`. The first of those is why the
config can say `~/.dotfiles/bashrc` and still work from any clone path. Re-running is
safe.

## Tools

- **[mise](https://mise.jdx.dev)** — tools, system packages, env, dotfile links.
  Also replaces Homebrew: it pours homebrew/core bottles itself, so `brew` need not
  be installed.
- **[jj](https://jj-vcs.github.io/jj)** — version control, colocated with git.
- **[herdr](https://herdr.dev)** — terminal multiplexer, and the sessions the agents
  run in. tmux is still here for now.
- **neovim**, **fzf**, **fd**, **ripgrep**, **bat**, **difftastic** — the usual.
- **Claude Code**, **pi**, **agy** — coding agents, sharing one `AGENTS.md`.

## Layout

```
config/mise/config.toml   the machine
config/                   app configs, symlinked into ~/.config
bashrc                    only what mise cannot express: functions, evals, prompt
agents/                   one AGENTS.md and the skills, shared by every agent
bin/                      herdr-jj, agent-guard, jj-workflow
claude/  pi/              per-harness settings
```

Machine-specific bits go in `config/mise/config.local.toml`, which is gitignored.
Work-specific bits go in `config.work.toml`, enabled with `echo work > ~/.mise-env`.

## Agents

Each agent gets its own **jj workspace** — a second working copy of the same repo —
so several can work in one project without touching each other's files, and the main
checkout stays mine. `bin/herdr-jj` creates and reaps those workspaces; `herdr` does
everything visual. `bin/agent-guard` is a `PreToolUse` hook that keeps an agent
inside its own workspace and asks before anything outward-facing, like a push.

With `ctrl+a` as the prefix: `shift+a` starts or attaches to an agent, `shift+d`
removes its workspace, `shift+y` sweeps dead ones. Everything else is stock herdr.

[AGENTS.md](AGENTS.md) holds the rules for agents working in this repo.
