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

-- Restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Restore cursor position when opening file",
  group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
