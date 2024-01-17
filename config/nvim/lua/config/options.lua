local opt = vim.opt

-- disable netrw in favor of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.breakindent = true --Enable break indent
opt.textwidth = 80
opt.colorcolumn = "120" -- Visual aid for detecting long lines
opt.completeopt = "menu,menuone,noselect"
opt.formatoptions = "tcqjroln" -- default is tcqj
opt.hlsearch = true --Set highlight on search
opt.ignorecase = true -- Ignore case sensitive match in search
opt.laststatus = 3 --Global statusline
opt.mouse = "" -- Disable mouse
opt.number = true --Show line numbers
opt.scrolloff = 7 -- Scroll offset
opt.signcolumn = "yes" -- Always show the signcolumn
opt.smartcase = true -- Match case in search if using uppercase
opt.undofile = true --Save undo history
opt.updatetime = 200 --Decrease update time
opt.termguicolors = true -- True color support
