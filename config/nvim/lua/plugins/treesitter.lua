return {
  -- Treesitter for better syntax highlighting and text objects
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      -- Core features you actually use
      highlight = { enable = true },
      indent = { enable = true },

      -- Automatic parser installation - installs parsers as you open files
      auto_install = true,

      -- Treesitter-based folding
      fold = { enable = true },

      -- Incremental selection (mapped to Ctrl-Space in keymaps)
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },

      -- Basic text objects for functions and classes
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },
    },
  },
}
