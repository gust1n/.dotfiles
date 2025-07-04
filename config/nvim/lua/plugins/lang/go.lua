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

-- Simple golangci-lint configuration that ignores exit codes
local function setup_golangci_lint()
  local ok, lint = pcall(require, "lint")
  if ok and lint.linters.golangcilint then
    -- Override the default linter to ignore exit codes
    lint.linters.golangcilint.ignore_exitcode = true
  end
end

-- Setup golangci-lint when nvim-lint is loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = setup_golangci_lint,
})

-- Linters
_G.LINTERS.go = { "golangcilint" }

-- Neotest adapters
add_neotest_adapter("neotest-golang", "fredrikaverpil/neotest-golang")

-- Mason tools needed
add_mason_tools({ "gopls", "goimports", "gofumpt", "golines", "golangci-lint" })

-- Fix Go import string colors while preserving namespace colors in code
-- This is just so that I can continue using the onedark there, plus gopls
-- semantic tokens but fix the very ugly mismatch with go import syntax highlighting.
local go_import_ns = vim.api.nvim_create_namespace("go_import_highlights")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "gopls" then
      -- Apply custom highlighting for Go imports after semantic tokens are applied
      local function fix_import_colors()
        local bufnr = args.buf
        vim.api.nvim_buf_clear_namespace(bufnr, go_import_ns, 0, -1)

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local in_import_block = false

        for i, line in ipairs(lines) do
          -- Check for import block start
          if line:match("^import%s*%(") then
            in_import_block = true
          elseif line:match("^import%s+") then
            -- Single line import
            local quote_start = line:find('"')
            if quote_start then
              local quote_end = line:find('"', quote_start + 1)
              if quote_end then
                -- Apply String highlight with higher priority than semantic tokens
                vim.api.nvim_buf_set_extmark(bufnr, go_import_ns, i - 1, quote_start - 1, {
                  end_col = quote_end,
                  hl_group = "String",
                  priority = 150, -- Higher than default semantic token priority (125)
                })
              end
            end
          elseif in_import_block then
            if line:match("^%)") then
              in_import_block = false
            else
              -- Multi-line import block
              local quote_start = line:find('"')
              if quote_start then
                local quote_end = line:find('"', quote_start + 1)
                if quote_end then
                  vim.api.nvim_buf_set_extmark(bufnr, go_import_ns, i - 1, quote_start - 1, {
                    end_col = quote_end,
                    hl_group = "String",
                    priority = 150,
                  })
                end
              end
            end
          end
        end
      end

      -- Apply fixes after semantic tokens are processed
      vim.defer_fn(function()
        fix_import_colors()
      end, 100)

      -- Reapply on text changes
      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost" }, {
        buffer = args.buf,
        callback = function()
          vim.defer_fn(fix_import_colors, 50)
        end,
      })
    end
  end,
})

-- Ensure syntax highlighting is set up correctly for Go
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    -- Reinforce that goImportString should link to String
    vim.api.nvim_set_hl(0, "goImportString", { link = "String" })
  end,
})
