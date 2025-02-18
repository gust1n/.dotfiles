-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
   local lazyrepo = "https://github.com/folke/lazy.nvim.git"
   local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
   if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
         { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
         { out, "WarningMsg" },
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

-- Load configuration from ./lua/config
require("config/options")
require("config/keymaps")
require("config/autocmds")

-- Setup lazy.nvim
require("lazy").setup({
   spec = {
      -- Load plugins from ./lua/plugins
      { import = "plugins" },
   },
   -- Configure any other settings here. See the documentation for more details.
   -- colorscheme that will be used when installing plugins.
   install = { colorscheme = { "onedark" } },
})

vim.cmd.colorscheme("onedark")
