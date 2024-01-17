-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
   vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
   })
end
vim.opt.rtp:prepend(lazypath)

-- Remap space as leader key, need to go before lazy setup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\" -- I don't use local leader

-- Load plugins from ./lua/plugins
require("lazy").setup("plugins")

-- Load configuration from ./lua/config
require("config/options")
require("config/keymaps")
require("config/autocmds")

vim.cmd.colorscheme("onedark")
