-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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

-- Leader must be set before lazy setup
vim.g.mapleader = " "

-- Disable netrw in favor of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Load configuration from ./lua/config
require("config/options")
require("config/keymaps")
require("config/autocmds")

require("config/lang")

-- Load every language file
local lang_path = vim.fn.stdpath("config") .. "/lua/plugins/lang"
local lang_files = vim.fn.glob(lang_path .. "/*.lua", false, true)
for _, file in ipairs(lang_files) do
  local lang_name = vim.fn.fnamemodify(file, ":t:r")
  require("plugins.lang." .. lang_name)
end

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- Load plugins from ./lua/plugins
    { import = "plugins" },
  },
  install = { colorscheme = { "onedark" } },
  change_detection = {
    notify = false,
  },
})

vim.cmd.colorscheme("onedark")
