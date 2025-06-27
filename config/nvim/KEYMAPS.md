# Neovim Key Mappings Reference

This document lists all configured key mappings in this Neovim configuration.

## Leader Key
- **Leader**: `<Space>`
- **Local Leader**: `\`

## Basic Editor Mappings

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-c>` | Insert | `<Esc>` | Escape insert mode |
| `k` | Normal | `gk` (wrap-aware) | Move up (respects word wrap) |
| `j` | Normal | `gj` (wrap-aware) | Move down (respects word wrap) |
| `<leader><cr>` | Normal | `:noh<CR>` | Clear search highlight |
| `<leader>o` | Normal | `o<Esc>k` | Insert line below and return to normal mode |
| `<leader>O` | Normal | `O<Esc>j` | Insert line above and return to normal mode |

## File and Project Navigation

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>t` | Normal | FzfLua files | Find files |
| `<leader>b` | Normal | FzfLua buffers | Find buffers |
| `<leader>f` | Normal | FzfLua grep_project | Grep project |
| `<leader>f` | Visual | FzfLua grep_visual | Grep selection |
| `<leader>p` | Normal | FzfLua builtin | FzfLua builtin commands |
| `<leader>kb` | Normal | NvimTreeToggle | Toggle file tree |

## LSP Mappings (when LSP is attached)

### Navigation
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `gd` | Normal | LSP go to definition | Go to definition |
| `gi` | Normal | FzfLua lsp_implementations | Go to implementation |
| `gr` | Normal | FzfLua lsp_references | Go to references |

### Documentation and Help
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `K` | Normal | LSP hover | Hover documentation |
| `<C-k>` | Normal | LSP signature help | Signature help |

### Code Actions and Refactoring
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>r` | Normal | LSP rename | Rename symbol |
| `<leader>a` | Normal/Visual | FzfLua lsp_code_actions | Code actions |

### Diagnostics
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<d` | Normal | vim.diagnostic.goto_prev | Previous diagnostic |
| `>d` | Normal | vim.diagnostic.goto_next | Next diagnostic |
| `<leader>e` | Normal | vim.diagnostic.open_float | Show diagnostic |

### Workspace
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>s` | Normal | FzfLua lsp_live_workspace_symbols | Workspace symbols |

## Diagnostic and Trouble Mappings

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>dd` | Normal | Trouble diagnostics toggle | Toggle diagnostics |
| `<leader>db` | Normal | Trouble diagnostics (buffer) | Buffer diagnostics |
| `<leader>ds` | Normal | Trouble symbols | Document symbols |
| `<leader>dr` | Normal | Trouble lsp_references | LSP references |
| `<leader>dq` | Normal | Trouble quickfix | Quickfix list |
| `dn` | Normal | Trouble diagnostics next | Next diagnostic (Trouble) |
| `dp` | Normal | Trouble diagnostics prev | Previous diagnostic (Trouble) |

## Text Editing and Selection

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-Space>` | Normal | Treesitter init selection | Start selection |
| `<C-Space>` | Visual | Treesitter expand selection | Expand selection |
| `<BS>` | Visual | Treesitter shrink selection | Shrink selection |

## UI and Window Management

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>w` | Normal | WinResizerStartResize | Resize windows |

## Tmux Navigation (nvim-tmux-navigation)

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-h>` | Normal | Navigate left | Move to left pane/window |
| `<C-j>` | Normal | Navigate down | Move to lower pane/window |
| `<C-k>` | Normal | Navigate up | Move to upper pane/window |
| `<C-l>` | Normal | Navigate right | Move to right pane/window |

## Language-Specific Notes

### Go Files
- All LSP mappings are available
- Formatters: `goimports`, `gofumpt`, `golines`

### Lua Files  
- All LSP mappings are available
- Formatter: `stylua`

## Tips

1. **LSP mappings** only become available when an LSP server is attached to the buffer
2. **Diagnostic mappings** work both with built-in diagnostics (`<d`, `>d`) and Trouble plugin (`dn`, `dp`)
3. **Search and replace** workflow: `<leader>f` to grep, then use replace tools
4. **File navigation** workflow: `<leader>t` for files, `<leader>b` for open buffers
5. **Code navigation** workflow: `gd` → `gr` → `<C-o>` to go back

## Configuration Location

All key mappings are centralized in `lua/config/keymaps.lua` for easy maintenance and overview.