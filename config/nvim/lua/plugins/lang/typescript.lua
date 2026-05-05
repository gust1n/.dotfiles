-- TypeScript/JavaScript language configuration

setup_filetype({ "typescript", "typescriptreact", "javascript", "javascriptreact" }, {
  indent = 2,
  expandtab = true,
  colorcolumn = 100,
})

-- LSP (tsgo from @typescript/native-preview in project node_modules)
vim.lsp.config("tsgo", {})
vim.lsp.enable("tsgo")

-- Formatters
_G.FORMATTERS.typescript = { "oxfmt" }
_G.FORMATTERS.typescriptreact = { "oxfmt" }
_G.FORMATTERS.javascript = { "oxfmt" }
_G.FORMATTERS.javascriptreact = { "oxfmt" }

-- Linters
_G.LINTERS.typescript = { "oxlint" }
_G.LINTERS.typescriptreact = { "oxlint" }
_G.LINTERS.javascript = { "oxlint" }
_G.LINTERS.javascriptreact = { "oxlint" }
