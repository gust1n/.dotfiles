-- Protobuf language configuration

setup_filetype({ "proto" }, {
  indent = 2,
  expandtab = true,
  colorcolumn = 120,
})

-- LSP
vim.lsp.config("buf_ls", {})
vim.lsp.enable("buf_ls")

-- Formatters
_G.FORMATTERS.proto = { "buf" }

-- Linters
_G.LINTERS.proto = { "protolint" }
