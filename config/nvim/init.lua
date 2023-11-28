-- install lazy.nvim
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

--Remap space as leader key, need to go before lazy setup
-- TODO: Is this first line needed?
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load plugins from ./plugins directory.
require("lazy").setup("plugins")

require("config/options")
require("config/keymaps")
require("config/autocmds")

vim.cmd.colorscheme("onedark")

-- LSP settings

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
   virtual_text = true,
   signs = true,
   update_in_insert = false,
})

-- language specific LSP setup
local lspconfig = require("lspconfig")
lspconfig.gopls.setup({
   settings = {
      gopls = {
         env = {
            GOFLAGS = "-tags=replay,e2e",
         },
         codelenses = {
            gc_details = false,
            generate = true,
            regenerate_cgo = true,
            run_govulncheck = true,
            test = true,
            tidy = true,
            upgrade_dependency = true,
            vendor = true,
         },
         hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
         },
         analyses = {
            fieldalignment = true,
            nilness = true,
            unusedparams = true,
            unusedwrite = true,
            useany = true,
         },
         usePlaceholders = true,
         completeUnimported = true,
         staticcheck = true,
         directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
         semanticTokens = true,
      },
   },
})
lspconfig.lua_ls.setup({
   settings = {
      Lua = {
         diagnostics = {
            globals = { "vim" },
         },
      },
   },
})
