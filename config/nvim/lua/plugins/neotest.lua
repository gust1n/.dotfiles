return {
  {
    "nvim-neotest/neotest",
    dependencies = (function()
      local base_deps = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
      }
      -- Add language-specific neotest dependencies
      vim.list_extend(base_deps, _G.NEOTEST_DEPENDENCIES or {})
      return base_deps
    end)(),
    config = function()
      require("neotest").setup({
        adapters = vim.tbl_map(function(name)
          return require(name)
        end, _G.NEOTEST_ADAPTERS or {}),
        icons = {
          running = "R",
          passed = "P",
          failed = "F",
          skipped = "S",
          unknown = "U",
          watching = "W",
          expanded = "v",
          child_prefix = "├",
          child_indent = "│",
          final_child_prefix = "└",
          final_child_indent = " ",
          non_collapsible = "─",
          collapsed = ">",
          notify = "N",
          test = "T",
        },
        quickfix = {
          enabled = true,
          open = false,
        },
        output = {
          enabled = true,
          open_on_run = "short",
        },
        status = {
          enabled = true,
          signs = true,
          virtual_text = false,
        },
      })
    end,
  },
}
