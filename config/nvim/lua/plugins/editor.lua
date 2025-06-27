return {
  { -- collection of mini plugins
    "echasnovski/mini.nvim",
    version = false,
    config = function(_, _)
      require("mini.ai").setup() -- Smart text objects
      require("mini.comment").setup() -- Syntax aware line commenting
      require("mini.move").setup() -- Move lines of code
      require("mini.surround").setup() -- Surround movement
      require("mini.starter").setup() -- Start screen
    end,
  },
  { -- navigate tmux and vim splits
    "alexghergh/nvim-tmux-navigation",
    config = function()
      require("nvim-tmux-navigation").setup({
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
          left = "<C-h>",
          down = "<C-j>",
          up = "<C-k>",
          right = "<C-l>",
        },
      })
    end,
  },
  { -- fzf based navigation and search
    "ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").setup({
        grep = {
          multiline = 1,
        },
      })
      require("fzf-lua").register_ui_select()
    end,
    keys = {
      { "<leader>b", "<cmd>lua require('fzf-lua').buffers()<cr>", desc = "FzfBuffers" },
      { "<leader>t", "<cmd>lua require('fzf-lua').files()<cr>", desc = "FzfFiles" },
      { "<leader>f", "<cmd>lua require('fzf-lua').grep_project()<cr>", desc = "FzfGrep" },
      { "<leader>f", "<cmd>lua require('fzf-lua').grep_visual()<cr>", desc = "FzFVisualGrep", mode = "v" },
    },
  },
  { -- file tree explorer
    "kyazdani42/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    keys = {
      { "<leader>kb", "<cmd>NvimTreeToggle<cr>", desc = "NvimTreeToggle" },
    },
    opts = {
      renderer = {
        icons = {
          show = {
            folder = false,
            file = false,
          },
          glyphs = {
            folder = {
              arrow_closed = ">",
              arrow_open = "v",
            },
          },
        },
      },
    },
  },
  { -- show git status in sign column
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      signs = {
        add = { text = "+" },
      },
    },
  },
  { -- formatter
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function(_, opts)
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = function(args)
          if vim.g.auto_format then
            require("conform").format({
              bufnr = args.buf,
              timeout_ms = 5000,
              lsp_format = "fallback",
            })
          else
          end
        end,
      })

      -- default to auto-format
      vim.g.auto_format = true

      require("conform").setup(opts)
    end,
  },
}
