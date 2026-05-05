-- Python language configuration

setup_filetype({ "python" }, {
  indent = 4,
  expandtab = true,
  colorcolumn = 88,
})

-- LSP (pyright)
vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "standard",
      },
    },
  },
})
vim.lsp.enable("pyright")

-- Formatters (ruff)
_G.FORMATTERS.python = { "ruff_format" }

-- Linters
_G.LINTERS.python = { "ruff" }
