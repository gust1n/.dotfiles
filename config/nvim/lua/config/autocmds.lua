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
      -- Buffer local mappings.
      local opts = { buffer = ev.buf }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gi", "<cmd>FzfLua lsp_implementations<CR>", opts)
      vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
      vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
      vim.keymap.set({ "n", "v" }, "<leader>a", "<cmd>lua require('fzf-lua').lsp_code_actions()<cr>", opts)
      vim.keymap.set("n", "gr", "<cmd>FzfLua lsp_references<CR>", opts)
      vim.keymap.set("n", "<d", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", ">d", vim.diagnostic.goto_next, opts)
      vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
      vim.keymap.set("n", "<leader>p", "<cmd>FzfLua builtin<CR>", opts)
      vim.keymap.set("n", "<leader>s", [[<cmd>lua require('fzf-lua').lsp_live_workspace_symbols()<CR>]], opts)
   end,
})
