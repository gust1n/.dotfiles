-- Flash selection on yank
vim.cmd([[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]])

-- When LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
   callback = function(ev)
      -- Use centralized LSP keymaps
      local keymaps = require("config.keymaps")
      keymaps.setup_lsp_mappings(ev.buf)
   end,
})
