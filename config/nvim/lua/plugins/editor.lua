return {
   {
      "echasnovski/mini.nvim",
      config = function()
         require("mini.ai").setup()
         require("mini.comment").setup()
         require("mini.move").setup()
         require("mini.surround").setup()
         require("mini.starter").setup()
      end,
   },
   {
      "alexghergh/nvim-tmux-navigation",
      config = function()
         require("nvim-tmux-navigation").setup({
            keybindings = {
               left = "<C-h>",
               down = "<C-j>",
               up = "<C-k>",
               right = "<C-l>",
            },
         })
      end,
   },
   {
      "ibhagwan/fzf-lua",
      config = function()
         require("fzf-lua").setup()
         require("fzf-lua").register_ui_select()
      end,
      keys = {
         { "<leader>b", "<cmd>FzfLua buffers<cr>",      desc = "Buffers" },
         { "<leader>t", "<cmd>FzfLua files<cr>",        desc = "Files" },
         { "<leader>f", "<cmd>FzfLua grep_project<cr>", desc = "Grep" },
         { "<leader>f", "<cmd>FzfLua grep_visual<cr>",  desc = "Visual Grep", mode = "v" },
      },
   },
   {
      "kyazdani42/nvim-tree.lua",
      cmd = "NvimTreeToggle",
      keys = {
         { "<leader>kb", "<cmd>NvimTreeToggle<cr>", desc = "File Tree" },
      },
      opts = {
         renderer = {
            icons = {
               show = { folder = false, file = false },
               glyphs = {
                  folder = { arrow_closed = ">", arrow_open = "v" },
               },
            },
         },
      },
   },
   {
      "lewis6991/gitsigns.nvim",
      event = "VeryLazy",
      opts = {
         signs = { add = { text = "+" } },
      },
   },
   {
      "stevearc/conform.nvim",
      event = "BufWritePre",
      cmd = "ConformInfo",
      dependencies = { "mason-org/mason.nvim" },
      opts = function()
         local lang = require("config.lang")
         return {
            formatters_by_ft = lang.get_formatters(),
            format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
         }
      end,
   },
}
