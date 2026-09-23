local opt = vim.opt

opt.breakindent = true -- Enable break indent
opt.ignorecase = true -- Ignore case sensitive match in search
opt.mouse = "" -- Disable mouse
opt.number = true -- Show line numbers
opt.scrolloff = 7 -- Scroll offset
opt.signcolumn = "yes" -- Always show the signcolumn
opt.smartcase = true -- Match case in search if using uppercase
opt.laststatus = 3 -- Global statusline
opt.undofile = true -- Save undo history
opt.updatetime = 200 -- Decrease update time
opt.termguicolors = true -- True color support
opt.swapfile = false -- disable annoying swap files

-- Folding options
opt.foldlevel = 99 -- Start with all folds open
opt.foldlevelstart = 99 -- Start with all folds open when opening files

-- Configure diagnostic signs to use ASCII symbols
vim.diagnostic.config({
  underline = true,
  virtual_text = false, -- Keep it clean, no inline text
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.INFO] = "I",
      [vim.diagnostic.severity.HINT] = "H",
    },
  },
  float = {
    border = "rounded",
    source = true,
    format = function(diagnostic)
      return diagnostic.code and ("[%s] %s"):format(diagnostic.code, diagnostic.message) or diagnostic.message
    end,
  },
  update_in_insert = false,
  severity_sort = true,
})
