-- Go language configuration

setup_filetype({ "go", "gomod", "gowork" }, {
  indent = 2,
  expandtab = false,
  colorcolumn = 120,
  textwidth = 120,
})

-- LSP
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      analyses = {
        ST1000 = false,
      },
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
      vulncheck = "Off",
      semanticTokens = false,
      linkTarget = "",
      linksInHover = false,
    },
  },
})
vim.lsp.enable("gopls")

-- Formatters
_G.FORMATTERS.go = { "golangci-lint" }

-- Linters
_G.LINTERS.go = { "golangcilint" }

-- Ignore exit codes from golangci-lint
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local ok, lint = pcall(require, "lint")
    if ok and lint.linters.golangcilint then
      lint.linters.golangcilint.ignore_exitcode = true
    end
  end,
})
