return {
  -- Colorscheme
  {
    "navarasu/onedark.nvim",
    opts = { style = "dark" },
  },

  -- Mini.nvim collection
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

  -- Navigation between tmux and nvim
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

  -- Fuzzy finder
  {
    "ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").setup()
      require("fzf-lua").register_ui_select()
    end,
  },

  -- File explorer
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

  -- Git integration
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

  -- Register peek
  {
    "junegunn/vim-peekaboo",
  },

  -- Window resizer
  {
    "simeji/winresizer",
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        icons_enabled = false,
        theme = "onedark",
        globalstatus = true,
        section_separators = "",
        component_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { "filename" },
        lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Trouble diagnostics
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    config = function()
      require("trouble").setup({
        signs = {
          error = "E",
          warning = "W",
          hint = "H",
          information = "I",
          other = "?",
        },
        icons = {
          indent = {
            fold_open = "v ",
            fold_closed = "> ",
          },
          folder_closed = "> ",
          folder_open = "v ",
        },
        -- Custom formatters to remove file and kind icons
        formatters = {
          file_icon = function(ctx)
            return ""
          end,
          kind_icon = function(ctx)
            return ""
          end,
        },
      })
    end,
  },

  -- Completion
  {
    "saghen/blink.cmp",
    lazy = false,
    version = "1.*",
    dependencies = "rafamadriz/friendly-snippets",
    opts = {
      completion = {
        menu = {
          auto_show = false, -- Don't show automatically
          draw = {
            components = {
              kind_icon = {
                ellipsis = false,
                text = function()
                  return ""
                end,
              },
            },
          },
        },
        trigger = {
          show_on_insert_on_trigger_character = false, -- Don't show on trigger characters
        },
      },
      keymap = {
        preset = "default", -- Uses <C-Space> to show completion
        ["<Tab>"] = { "accept", "fallback" },
      },
      signature = {
        enabled = true, -- Enable experimental signature help
      },
    },
  },
}
