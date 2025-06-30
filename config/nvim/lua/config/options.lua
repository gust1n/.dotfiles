local opt = vim.opt

-- disable netrw in favor of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.breakindent = true -- Enable break indent
opt.textwidth = 80
opt.hlsearch = true -- Set highlight on search
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
      local source = diagnostic.source and ("[%s] "):format(diagnostic.source) or ""
      local code = diagnostic.code and ("[%s] "):format(diagnostic.code) or ""
      return ("%s%s%s"):format(source, code, diagnostic.message)
    end,
  },
  update_in_insert = false,
  severity_sort = true,
})
