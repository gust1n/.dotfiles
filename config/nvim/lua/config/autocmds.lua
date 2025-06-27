-- Flash selection on yank (modern autocmd)
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- When LSP attaches (modern with better error handling)
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Setup LSP keymaps when server attaches",
  group = vim.api.nvim_create_augroup("LspAttach", { clear = true }),
  callback = function(ev)
    -- Use centralized LSP keymaps
    local ok, keymaps = pcall(require, "config.keymaps")
    if ok then
      keymaps.setup_lsp_mappings(ev.buf)
    else
      vim.notify("Failed to load LSP keymaps", vim.log.levels.WARN)
    end
  end,
})
