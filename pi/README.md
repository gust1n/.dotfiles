# pi agent config

| File | Tracked | What |
|---|---|---|
| `settings.json` | ✅ | pi settings. Symlinked to `~/.pi/agent/settings.json`. |
| `extensions/*.ts` | ✅ | pi extensions. The directory is symlinked. |

Both links are `[dotfiles]` entries in `config/mise/config.toml` and are applied
by `mise bootstrap`. There is no sync script and no `settings.local.json`.

Because `settings.json` is a symlink, pi writes its own state
(`lastChangelogVersion`, `theme`) straight into this repo. Those edits show up in
`jj diff` — commit them or discard them.

Model IDs come from `[env]` in `config/mise/config.toml`, except the `subagents`
entries here, which pi reads from this file.

`AGENTS.md` comes from `agents/AGENTS.md`, shared with every other harness.
