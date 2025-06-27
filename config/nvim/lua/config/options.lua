local opt = vim.opt

-- disable netrw in favor of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.colorcolumn = "120"
opt.mouse = ""
opt.scrolloff = 7
opt.signcolumn = "yes"
opt.laststatus = 3
opt.updatetime = 200
