return {
   'tpope/vim-fugitive',             -- Git explorer
   'tpope/vim-commentary',           -- Smart commenting
   'tpope/vim-surround',             -- Surround movement
   'christoomey/vim-tmux-navigator', -- navigate tmux and vim splits
   -- fzf based navigation and search
   {
      "ibhagwan/fzf-lua",
      keys = {
         { "<leader>a", "<cmd>lua require('fzf-lua').lsp_code_actions()<cr>",   desc = "FzfLspCodeActions" },
         { "<leader>b", "<cmd>lua require('fzf-lua').buffers()<cr>",            desc = "FzfBuffers" },
         { "<leader>t", "<cmd>lua require('fzf-lua').files()<cr>",              desc = "FzfFiles" },
         { "<leader>f", "<cmd>lua require('fzf-lua').grep({ search = ''})<cr>", desc = "FzfGrep" },
         { "<leader>f", "<cmd>lua require('fzf-lua').grep_visual()<cr>",        desc = "FzFVisualGrep",    mode = "v" },
      },
   },
   -- file tree explorer
   {
      'kyazdani42/nvim-tree.lua',
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
                  }
               }
            }
         },
      }
   },
   -- show git status in sign column
   {
      'lewis6991/gitsigns.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      event = "VeryLazy",
      opts = {
         signs = {
            add = { hl = 'GitGutterAdd', text = '+' },
            change = { hl = 'GitGutterChange', text = '~' },
            delete = { hl = 'GitGutterDelete', text = '_' },
            topdelete = { hl = 'GitGutterDelete', text = '‾' },
            changedelete = { hl = 'GitGutterChange', text = '~' },
         },
      }
   },
}
