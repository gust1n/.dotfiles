-- go specific tab editor settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = false

    vim.opt_local.colorcolumn = "120"
  end,
})

local tags = "-tags=integration"

return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "gofumpt", "goimports", "gci", "golines" })
        end,
      },
    },
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gci", "gofumpt", "golines" },
      },
      formatters = {
        goimports = {
          -- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/goimports.lua
          args = { "-srcdir", "$FILENAME" },
        },
        gci = {
          -- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/gci.lua
          args = { "write", "--skip-generated", "-s", "standard", "-s", "default", "--skip-vendor", "$FILENAME" },
        },
        gofumpt = {
          -- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/gofumpt.lua
          prepend_args = { "-extra", "-w", "$FILENAME" },
          stdin = false,
        },
        golines = {
          -- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/golines.lua
          -- NOTE: golines will use goimports as base formatter by default which can be slow.
          -- see https://github.com/segmentio/golines/issues/33
          prepend_args = { "--base-formatter=gofumpt", "--ignore-generated", "--tab-len=1", "--max-len=120" },
        },
      },
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "mason-org/mason-lspconfig.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "gopls" })
        end,
      },
    },
    opts = {
      servers = {
        gopls = {
          cmd = { "gopls" },
          filetypes = { "go", "gomod", "gowork", "gosum" },
          root_markers = { "go.work", "go.mod", ".git" },
          settings = {
            gopls = {
              buildFlags = { tags },
              -- env = {},
              -- analyses = {
              --   -- https://github.com/golang/tools/blob/master/gopls/internal/settings/analysis.go
              --   -- https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
              -- },
              -- codelenses = {
              --   -- https://github.com/golang/tools/blob/master/gopls/doc/codelenses.md
              --   -- https://github.com/golang/tools/blob/master/gopls/internal/settings/settings.go
              -- },
              hints = {
                -- https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
                -- https://github.com/golang/tools/blob/master/gopls/internal/settings/settings.go

                parameterNames = true,
                assignVariableTypes = true,
                constantValues = true,
                compositeLiteralTypes = true,
                compositeLiteralFields = true,
                functionTypeParameters = true,
              },
              -- completion options
              -- https://github.com/golang/tools/blob/master/gopls/doc/features/completion.md
              -- https://github.com/golang/tools/blob/master/gopls/internal/settings/settings.go

              -- build options
              -- https://github.com/golang/tools/blob/master/gopls/internal/settings/settings.go
              -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#build
              directoryFilters = { "-**/node_modules", "-**/.git", "-.vscode", "-.idea", "-.vscode-test" },

              -- formatting options
              -- https://github.com/golang/tools/blob/master/gopls/internal/settings/settings.go
              gofumpt = false, -- handled by conform instead.

              -- ui options
              -- https://github.com/golang/tools/blob/master/gopls/internal/settings/settings.go
              semanticTokens = false, -- disabling this enables treesitter injections (for sql, json etc)

              -- diagnostic options
              -- https://github.com/golang/tools/blob/master/gopls/internal/settings/settings.go
              staticcheck = true,
              vulncheck = "imports",
              analysisProgressReporting = true,
            },
          },
        },
      },
    },
  },
}
