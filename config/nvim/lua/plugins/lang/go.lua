-- Go language configuration

-- File type settings
setup_filetype({ "go", "gomod", "gowork" }, {
  indent = 2,
  expandtab = false,
  colorcolumn = 120,
})

-- LSP server configuration
_G.LSP_SERVERS.gopls = {
  settings = {
    gopls = {
      buildFlags = { "-tags=integration" },
      hints = {
        parameterNames = true,
        assignVariableTypes = true,
        constantValues = true,
        compositeLiteralTypes = true,
        compositeLiteralFields = true,
        functionTypeParameters = true,
      },
      staticcheck = true,
      vulncheck = "imports",
      semanticTokens = true,
    },
  },
}

-- Formatters
_G.FORMATTERS.go = { "goimports", "gofumpt", "golines" }

-- Linters
_G.LINTERS.go = { "golangcilint" }

-- Neotest adapters
add_neotest_adapter("neotest-golang", "fredrikaverpil/neotest-golang")

-- Mason tools needed
add_mason_tools({ "gopls", "goimports", "gofumpt", "golines", "golangci-lint" })
