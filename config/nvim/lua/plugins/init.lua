return {
   {
      'neovim/nvim-lspconfig', -- Collection of configurations for built-in LSP client
      -- This is due to some weird mod_cache issue introduced in
      -- https://github.com/neovim/nvim-lspconfig/commit/9a2cc569c88662fa41d414bdb65b13ea72349f86
      commit = '80861dc087982a6ed8ba91ec4836adce619f5a8a',
   },

   'christoomey/vim-system-copy',   -- Copy to system clipboard

   'tpope/vim-fugitive',            -- Git
   'tpope/vim-commentary',          -- Smart commenting
   'tpope/vim-surround',            -- Surround movement

   'editorconfig/editorconfig-vim', -- Read .editorconfig files
   'junegunn/vim-peekaboo',         -- Peek registers

   'ibhagwan/fzf-lua',
   {
      'lewis6991/gitsigns.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
         require('gitsigns').setup {
            signs = {
               add = { hl = 'GitGutterAdd', text = '+' },
               change = { hl = 'GitGutterChange', text = '~' },
               delete = { hl = 'GitGutterDelete', text = '_' },
               topdelete = { hl = 'GitGutterDelete', text = '‾' },
               changedelete = { hl = 'GitGutterChange', text = '~' },
            },
         }
      end
   },
   {
      'ray-x/lsp_signature.nvim', -- function signature hints
      config = function()
         require("lsp_signature").setup {
            bind = true,
            hi_parameter = "IncSearch",
            hint_enable = false,
            floating_window = true,
            floating_window_above_cur_line = false,
            doc_lines = 0,
         }
      end
   },
   'christoomey/vim-tmux-navigator',
   {
      "folke/trouble.nvim",
      config = function()
         require("trouble").setup {
            position = "bottom",
            icons = false,
            fold_open = "v",      -- icon used for open folds
            fold_closed = ">",    -- icon used for closed folds
            indent_lines = false, -- add an indent guide below the fold icons
            auto_open = true,     -- automatically open the list when you have diagnostics
            auto_close = true,    -- automatically close the list when you have no diagnostics
            auto_preview = false, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
            signs = {
               -- icons / text used for a diagnostic
               error = "error",
               warning = "warn",
               hint = "hint",
               information = "info"
            },
            use_diagnostic_signs = true -- enabling this will use the signs defined in your lsp client
         }
      end
   },
}
