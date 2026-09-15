# dotfiles

Personal dotfiles of gust1n. 

Managed almost fully by `mise` and manages tools, system packages, environment, shell aliases etc.

## Bootstrap

```bash
curl https://mise.run | sh
git clone https://github.com/gust1n/.dotfiles ~/Code/dotfiles
~/Code/dotfiles/install.sh
```

`install.sh` symlinks `~/.dotfiles` to the checkout and `~/.config/mise` to
`config/mise`, then hands over to `mise bootstrap` (which should be idempotent).

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

Each agent gets its own **jj workspace** so several can work in one project in isolation.
`bin/herdr-jj` creates and reaps those workspaces; `herdr` does everything visual. 
`bin/agent-guard` is a `PreToolUse` hook that keeps an agent inside its own workspace 
and asks before anything outward-facing, like a push.

With `ctrl+a` as the prefix: `shift+a` starts or attaches to an agent, `shift+d`
removes its workspace, `shift+y` sweeps dead ones. Everything else is stock herdr.

[AGENTS.md](AGENTS.md) holds the rules for agents working in this repo.
