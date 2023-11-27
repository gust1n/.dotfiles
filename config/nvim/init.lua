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
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load plugins from ./plugins directory.
require('lazy').setup('plugins')

require('config/options')
require('config/keymaps')

vim.cmd [[colorscheme base16-tomorrow-night-eighties]]

-- Flash selection on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- LSP settings

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
   vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = true,
      signs = true,
      update_in_insert = false,
   }
)

local function has_value(tab, val)
   for _, value in ipairs(tab) do
      if value == val then
         return true
      end
   end

   return false
end

-- control which LSP formatting is used
local lsp_formatting = function(bufnr)
   vim.lsp.buf.format({
      filter = function(client)
         -- use null-ls for go (discard gopls)
         if has_value(client.config.filetypes, 'go') then
            return client.name == "null-ls"
         end
         return true
      end,
      bufnr = bufnr,
   })
end

-- group for enabling auto format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- language specific LSP setup
local lspconfig = require 'lspconfig'
lspconfig.gopls.setup {
   settings = {
      gopls = {
         env = {
            GOFLAGS = "-tags=replay,e2e"
         }
      }
   }
}
lspconfig.lua_ls.setup {
   settings = {
      Lua = {
         diagnostics = {
            globals = { 'vim' }
         }
      }
   }
}

vim.api.nvim_create_autocmd('LspAttach', {
   callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      vim.api.nvim_buf_set_option(args.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

      if client.supports_method("textDocument/formatting") then
         vim.api.nvim_clear_autocmds({ group = augroup, buffer = args.buf })
         vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = args.buf,
            callback = function()
               lsp_formatting(args.buf)
            end,
         })
      end

      local opts = { buffer = args.buf }
      vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.keymap.set('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
      vim.keymap.set('n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      vim.keymap.set('n', 'gr', '<cmd>FzfLua lsp_references<CR>', opts)
      vim.keymap.set('n', '<d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
      vim.keymap.set('n', '>d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
      vim.keymap.set('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
      vim.keymap.set('n', '<leader>p', [[<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>]], opts)
      vim.keymap.set('n', '<leader>s', [[<cmd>lua require('fzf-lua').lsp_live_workspace_symbols()<CR>]], opts)
   end,
})
