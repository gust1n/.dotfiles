local lang = require("config.lang")

-- File type settings
lang.setup_filetype({ "go", "gomod", "gowork" }, {
  indent = 2,
  expandtab = false,
  colorcolumn = 120,
})

-- LSP configuration
lang.lsp("gopls", {
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
      semanticTokens = false,
    },
  },
})

-- Formatters
lang.formatters({ "go" }, { "goimports", "gofumpt", "golines" }, { "goimports", "gofumpt", "golines" })

-- Neotest configuration
lang.neotest({ "go" }, {
  "neotest-golang",
})

-- Language files don't return anything - they just register configuration
