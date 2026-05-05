# Neovim Agent Guide

## Scope

- Path: `config/nvim/`
- Runtime target: `~/.config/nvim` (symlinked by `install.sh`)
- Source of truth: this directory

## Strategy

- lazy.nvim for plugin management
- Minimal plugin surface, prefer built-ins when equivalent
- Split by concern: core config, plugins, per-language settings
- Global tables (`_G.LSP_SERVERS`, `_G.FORMATTERS`, `_G.LINTERS`) wire language configs to plugins
- Tools (LSP servers, formatters, linters) are installed externally via mise, not managed by neovim

## Symlink

- `install.sh` symlinks all `config/*/` directories to `~/.config/`
- Behavior: entire `config/nvim/` is mounted as `~/.config/nvim`
- New files are auto-available at runtime

## Directory Layout

- `init.lua`
  - lazy.nvim bootstrap, leader key, loads config modules, auto-loads lang files, sets up lazy plugin spec
- `lua/config/options.lua`
  - editor options, diagnostic config
- `lua/config/keymaps.lua`
  - global keymaps, exports `setup_lsp_mappings()` for LspAttach
- `lua/config/autocmds.lua`
  - non-plugin autocmds (yank highlight, LspAttach, cursor restore)
- `lua/config/lang.lua`
  - initializes global tables + helper functions for language files
- `lua/plugins/plugins.lua`
  - general plugins (colorscheme, mini.nvim, fzf-lua, nvim-tree, gitsigns, lualine, trouble)
- `lua/plugins/lsp.lua`
  - nvim-lspconfig setup, iterates `_G.LSP_SERVERS`
- `lua/plugins/conform.lua`
  - format-on-save via conform.nvim, uses `_G.FORMATTERS`
- `lua/plugins/nvim-lint.lua`
  - linting via nvim-lint, uses `_G.LINTERS`
- `lua/plugins/treesitter.lua`
  - treesitter config (highlight, indent, incremental selection, textobjects)
- `lua/plugins/neotest.lua`
  - test runner, adapters from `_G.NEOTEST_ADAPTERS`
- `lua/plugins/lang/*.lua`
  - per-language config files (LSP, formatters, linters, filetype settings)
- `after/queries/go/injections.scm`
  - treesitter injection queries for SQL/JSON in Go strings

## Module Naming

- Namespace: `config` for core, `plugins` for plugin specs, `plugins.lang` for languages
- Require pattern: `require("config.keymaps")`, `require("plugins.lang.go")`

## Language Configuration Pattern

Each `lua/plugins/lang/<lang>.lua` file:
1. Calls `setup_filetype()` for indent/colorcolumn settings
2. Populates `_G.LSP_SERVERS.<server>` with config
3. Sets `_G.FORMATTERS.<ft>` and `_G.LINTERS.<ft>`
4. Optionally calls `add_neotest_adapter()` for test support

Tools (LSP servers, formatters, linters) must be installed on PATH via mise — see `config/mise/config.toml`.

Language files are auto-loaded by `init.lua` before lazy.nvim setup.

## LSP Rules

- Server configs defined in `lua/plugins/lang/*.lua` via `_G.LSP_SERVERS`
- `lua/plugins/lsp.lua` iterates the table, calls `vim.lsp.config()` + `vim.lsp.enable()`
- LSP keymaps set up in `lua/config/autocmds.lua` via LspAttach event
- Root markers: relies on lspconfig defaults (includes `.git`)

## Editing Rules

- Keep `init.lua` thin - only bootstrap and loading
- Core editor config in `lua/config/*`
- Plugin specs in `lua/plugins/*.lua`
- Language-specific behavior in `lua/plugins/lang/*.lua`
- Format with stylua (see `.stylua.toml`: 120 columns, 2-space indent, double quotes)
- Do not add plugins without clear justification

## Commands

- Startup validation:

```sh
nvim --headless '+qa'
```

- Check health:

```sh
nvim --headless '+checkhealth' '+qa'
```

- Sync plugins:

```sh
nvim --headless "+Lazy! sync" +qa
```

## Style

- Formatting: stylua with `.stylua.toml` (120 col, 2 spaces, double quotes)
- No icons/nerd fonts in UI - use ASCII symbols (E/W/I/H for diagnostics, +/~/- for git)
- Colorscheme: onedark (dark style)
- Global statusline (`laststatus = 3`)
