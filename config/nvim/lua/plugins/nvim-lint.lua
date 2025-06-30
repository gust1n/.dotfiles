return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      local lint = require("lint")

      -- Use linters from language configurations
      lint.linters_by_ft = _G.LINTERS or {}

      -- Simple lint autocommands
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })

      -- Add useful commands
      vim.api.nvim_create_user_command("LintManual", function()
        lint.try_lint()
      end, { desc = "Manually trigger linting" })

      vim.api.nvim_create_user_command("LintStatus", function()
        local diags = vim.diagnostic.get(0)
        print("=== Lint Status ===")
        print("File: " .. vim.fn.expand("%:t"))
        print(
          "Linters configured for " .. vim.bo.filetype .. ": " .. vim.inspect(lint.linters_by_ft[vim.bo.filetype] or {})
        )
        print("Found " .. #diags .. " issue(s):")
        if #diags == 0 then
          print("  ✓ No linting issues found")
        else
          for _, diag in ipairs(diags) do
            local severity = diag.severity == 1 and "ERROR" or diag.severity == 2 and "WARN" or "INFO"
            print("  " .. severity .. " Line " .. (diag.lnum + 1) .. ": " .. diag.message)
          end
        end
      end, { desc = "Show current linting status" })
    end,
  },
}
