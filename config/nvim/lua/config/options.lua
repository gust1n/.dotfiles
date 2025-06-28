local opt = vim.opt

-- disable netrw in favor of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.colorcolumn = "120"
opt.mouse = ""
opt.scrolloff = 7
opt.signcolumn = "yes"
opt.laststatus = 3
opt.updatetime = 200

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
    source = "always",
    format = function(diagnostic)
      local source = diagnostic.source and ("[%s] "):format(diagnostic.source) or ""
      local code = diagnostic.code and ("[%s] "):format(diagnostic.code) or ""
      return ("%s%s%s"):format(source, code, diagnostic.message)
    end,
  },
  update_in_insert = false,
  severity_sort = true,
})
