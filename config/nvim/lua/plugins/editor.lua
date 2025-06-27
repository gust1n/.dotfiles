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
   },
   {
      "kyazdani42/nvim-tree.lua",
      cmd = "NvimTreeToggle",
      opts = {
         renderer = {
            icons = {
               show = {
                  folder = false,
                  file = false,
                  folder_arrow = true,
                  git = true,
               },
               glyphs = {
                  default = "",
                  symlink = "@",
                  bookmark = "B",
                  folder = {
                     arrow_closed = ">",
                     arrow_open = "v",
                     default = "[D]",
                     open = "[O]",
                     empty = "[E]",
                     empty_open = "[EO]",
                     symlink = "[S]",
                     symlink_open = "[SO]",
                  },
                  git = {
                     unstaged = "M",
                     staged = "S",
                     unmerged = "U",
                     renamed = "R",
                     untracked = "?",
                     deleted = "D",
                     ignored = "I",
                  },
               },
            },
         },
         git = {
            enable = true,
            ignore = false,
         },
         diagnostics = {
            enable = true,
            show_on_dirs = true,
            icons = {
               hint = "H",
               info = "I",
               warning = "W",
               error = "E",
            },
         },
      },
   },
   {
      "lewis6991/gitsigns.nvim",
      event = "VeryLazy",
      opts = {
         signs = {
            add = { text = "+" },
            change = { text = "~" },
            delete = { text = "-" },
            topdelete = { text = "^" },
            changedelete = { text = "~" },
            untracked = { text = "?" },
         },
         signcolumn = true,
         current_line_blame = false,
         current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol",
            delay = 1000,
         },
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
