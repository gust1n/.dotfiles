-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
   local lazyrepo = "https://github.com/folke/lazy.nvim.git"
   local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
   if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
         { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
         { out,                            "WarningMsg" },
         { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
   end
end
vim.opt.rtp:prepend(lazypath)

-- Remap space as leader key, need to go before lazy setup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\" -- I don't use local leader

-- Disable netrw in favor of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Ensure Mason's bin directory is in PATH early
local mason_path = vim.fn.stdpath("data") .. "/mason/bin"
local current_path = vim.env.PATH or ""
if not string.find(current_path, mason_path, 1, true) then
   vim.env.PATH = mason_path .. ":" .. current_path
end

-- Load configuration from ./lua/config
require("config/options")
require("config/keymaps")
require("config/autocmds")

-- Load language configurations (registers LSP and formatter configs)
require("plugins/lang/lua")
require("plugins/lang/go")

-- Setup lazy.nvim
require("lazy").setup({
   spec = {
      -- Load plugins from ./lua/plugins
      { import = "plugins" },
   },
   -- Configure any other settings here. See the documentation for more details.
   -- colorscheme that will be used when installing plugins.
   install = { colorscheme = { "onedark" } },
   change_detection = {
      notify = false, -- get a notification when changes are found
   },
})

vim.cmd.colorscheme("onedark")
