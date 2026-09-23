# Neovim Agent Guide

`config/nvim/` is linked to `~/.config/nvim` by `[dotfiles]` in `config.toml`.

## Layout

- `init.lua` — lazy.nvim bootstrap, leader, loads `config/*`, auto-loads every `plugins/lang/*.lua`, then lazy setup. Keep it thin.
- `lua/config/options.lua` — options, diagnostic config.
- `lua/config/keymaps.lua` — global keymaps; exports `setup_lsp_mappings()` for `LspAttach`.
- `lua/config/autocmds.lua` — treesitter start, yank highlight, `LspAttach`, cursor restore.
- `lua/config/lang.lua` — defines `_G.FORMATTERS`, `_G.LINTERS`, `setup_filetype()`.
- `lua/plugins/*.lua` — plugin specs. `conform.lua` reads `_G.FORMATTERS`; `nvim-lint.lua` reads `_G.LINTERS`.
- `lua/plugins/lang/<lang>.lua` — one file per language.
- `after/queries/go/injections.scm` — SQL/JSON injection in Go strings.

## Language files

Each `lua/plugins/lang/<lang>.lua`:
1. Calls `setup_filetype()` for indent and colorcolumn.
2. Calls `vim.lsp.config()` and `vim.lsp.enable()` for its server.
3. Sets `_G.FORMATTERS.<ft>` and `_G.LINTERS.<ft>`.

- LSP servers, formatters and linters come from `[tools]` in mise. Neovim installs none of them.
- Add a new language's parser to the list in `lua/plugins/treesitter.lua`.

## Rules

- Do not add plugins without clear justification. Prefer built-ins.
- No icons or nerd fonts in the UI. Use ASCII (E/W/I/H, +/~/-).
- Format with stylua (`.stylua.toml`).

## Verify

```sh
stylua --check lua/
nvim --headless '+qa'
```
