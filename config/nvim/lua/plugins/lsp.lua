return {
  { -- Collection of configurations for built-in LSP client
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
    },
    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        severity_sort = true,
      },
      -- custom LSP server setup configuration
      servers = {},
    },
    config = function(_, opts)
      -- Setup global diagnostics configuration
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Setup individual servers
      local servers = opts.servers
      for server, server_opts in pairs(servers) do
        if server_opts then
          require("lspconfig")[server].setup(server_opts)
        end
      end
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    -- NOTE: this is here because mason-lspconfig must install servers prior to running nvim-lspconfig
    lazy = false,
    dependencies = {
      {
        -- NOTE: this is here because mason.setup must run prior to running nvim-lspconfig
        -- see mason.lua for more settings.
        "mason-org/mason.nvim",
        lazy = false,
      },
    },
  },
  { -- Function signature hints
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {
      bind = true,
      hi_parameter = "IncSearch",
      hint_enable = false,
      floating_window = true,
      floating_window_above_cur_line = true,
      doc_lines = 0,
      toggle_key = "<C-k>",
    },
  },
  { -- Fancy LSP diagnostics
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
      icons = {
        indent = {
          top = "│ ",
          middle = "├╴",
          last = "└╴",
          fold_open = "> ",
          fold_closed = "v ",
        },
        folder_closed = "> ",
        folder_open = "v ",
        kinds = {
          File = "□ ",
        },
      },
      auto_close = true, -- automatically close the list when you have no diagnostics
      auto_preview = false, -- automatically preview the location of the diagnostic.
    },
    keys = {
      { "<leader>dd", "<cmd>Trouble diagnostics toggle focus=false<cr>", desc = "Workspace Diagnostics (Trouble)" },
      {
        "dn",
        function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous trouble/quickfix item",
      },
      {
        "dp",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next trouble/quickfix item",
      },
    },
  },
}
