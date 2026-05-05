-- Enable treesitter highlighting for all filetypes with a parser
vim.api.nvim_create_autocmd("FileType", {
  desc = "Start treesitter highlighting",
  group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].syntax = ""
    end
  end,
})

-- Flash selection on yank (modern autocmd)
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking text",
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- LSP defaults
vim.lsp.config("*", {
  capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          resolveSupport = { properties = { "documentation", "detail", "additionalTextEdits" } },
        },
      },
      foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
    },
  },
})

-- When LSP attaches
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Setup LSP keymaps and folding",
  group = vim.api.nvim_create_augroup("LspAttach", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.server_capabilities.foldingRangeProvider then
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
      vim.opt_local.foldtext = "v:lua.vim.lsp.foldtext()"
      vim.opt_local.foldenable = true
      vim.opt_local.foldlevel = 99
    end
    require("config.keymaps").setup_lsp_mappings(ev.buf)
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
