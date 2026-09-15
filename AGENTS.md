# Rules for working in this repo

Personal workflow rules (jj, code style, writing style) come from
`agents/AGENTS.md`, already loaded as your global instructions. Do not repeat them
here. [README.md](README.md) is a short public overview; keep it that way. Rationale
belongs in a comment next to the config it explains, not in either file.

## Everything declarative goes in `config/mise/config.toml`

`[tools]`, `[bootstrap.packages]`, `[env]`, `[shell_alias]`, `[dotfiles]`,
`[bootstrap.repos]`. Only shell functions, `eval` integrations and the prompt belong
in `bashrc`. Never add an env var, `PATH` entry or alias to `bashrc`.

Machine-specific values go in `config.local.toml` (gitignored). Work values go in
`config.work.toml`.

## Traps that will bite you

- **`[dotfiles]` sources must be written `~/.dotfiles/…`.** Never a real path, never
  relative, never templated — all three break. `~/.dotfiles` is a symlink
  `install.sh` points at the checkout, so this is already location-independent: do
  not "fix" it to wherever the repo happens to be.
- **`bashrc` and `bash_profile` are copies, not symlinks.** Editing them does
  nothing until `mise run link`.
- **Never add `~/.config/mise` to `[dotfiles]`**, and do not glob `~/.config/*`.
  A glob puts it in reach of `unapply`, which would delete the link mise needs to
  find its own config, leaving nothing able to restore it. List config dirs one by
  one.
- **Never put `[env]` or `[shell_alias]` in `config.macos.toml`.** Interactive
  shells do not set `MISE_ENV=macos`, so they would never apply. Use a portable
  value in `config.toml` instead — `CLICOLOR=1`, not an `ls -G` alias.
- **Never export `PROMPT_COMMAND`.** Nested shells inherit it and append again.
- **`[bootstrap.repos]` and tmux.conf's `set -g @plugin` lines are one list.**
  Change both or neither.

## Model IDs

`[vars]` in `config.toml` is the only place they are written. Everything reads them
from `[env]`. The single exception is `pi/settings.json`, whose `subagents` IDs pi
reads from its own file — update both when changing a generation.

## Settings files write themselves

`claude/settings.json` and `pi/settings.json` are symlinked into `$HOME`, so the
harnesses write their own state (`model`, `theme`, `effortLevel`,
`lastChangelogVersion`) straight into the working copy. Those diffs are expected.
Do not revert them as if they were accidental, and do not add generator scripts.

## Verify before reporting done

```bash
./install.sh                          # idempotent; must end with no changes
mise bootstrap plan                   # expect 0 create, 0 update, 0 remove
mise bootstrap dotfiles status        # expect every target `applied`
mise run drift                        # expect exit 0
bash -n bashrc bash_profile install.sh
```

For shell changes, also check a fresh login shell. Note that `bash -c` never reads
the history file, even with `-i`, so drive a real interactive shell if you are
testing history.

## Editing docs

`CLAUDE.md` symlinks to this file. Never edit a derivative — edit the target.
Keep this file to rules an agent must obey.
