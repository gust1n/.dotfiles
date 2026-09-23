# Rules for working in this repo

Personal workflow rules (jj, code style, writing style) come from
`agents/AGENTS.md`, already loaded as your global instructions. Do not repeat them
here. [README.md](README.md) is a short public overview; keep it that way. Rationale
belongs in a comment next to the config it explains, not in either file.

## Everything declarative goes in `config.toml`

This repo is `~/.config/mise`. `~/Code/dotfiles` is a link to it. A new machine
is set up only with `mise bootstrap --adopt gust1n/.dotfiles --yes` (see README).
Never add a setup script: put each step in mise config or a `[bootstrap.hooks]`
entry.

`[tools]`, `[bootstrap.*]`, `[env]`, `[shell_alias]`, `[dotfiles]`. Only shell
functions, `eval` integrations and the prompt belong in `bashrc`. Never add an env
var, `PATH` entry or alias to `bashrc`.

- OS-specific values go in `config.macos.toml` or `config.linux.toml`. They load
  automatically (`auto_env` in `miserc.toml`). Both must keep working.
- Machine-specific values go in `config.local.toml` (gitignored).
- Work values go in `config.work.toml`.

## Traps that will bite you

- **`[dotfiles]` sources are relative to the repo root.** Never write an absolute
  or `~/` source.
- **Every directory in `config/` is linked into `~/.config`** by one glob. A new
  directory there is linked on the next apply.
- **`bashrc` and `bash_profile` are copies, not symlinks.** Editing them does
  nothing until `mise run link`.
- **Never export `PROMPT_COMMAND`.** Nested shells inherit it and append again.

## Model IDs

`[vars]` in `config.toml` is the only place they are written. Everything reads them
from `[env]`, so a generation change is one edit.

## Settings files write themselves

`claude/settings.json` is symlinked into `$HOME`, so Claude Code writes its own
state (`model`, `theme`, `effortLevel`) straight into the working copy. Those diffs
are expected. Do not revert them as if they were accidental.

## Verify before reporting done

```bash
mise bootstrap --yes                  # idempotent; must end with no changes
mise bootstrap plan                   # expect 0 create, 0 update, 0 remove
mise bootstrap dotfiles status        # expect every target `applied`
mise run drift                        # expect exit 0
bash -n bashrc bash_profile bin/*
```

For shell changes, also check a fresh login shell. Note that `bash -c` never reads
the history file, even with `-i`, so drive a real interactive shell if you are
testing history.

## Editing docs

`CLAUDE.md` symlinks to this file. Never edit a derivative — edit the target.
Keep this file to rules an agent must obey.
