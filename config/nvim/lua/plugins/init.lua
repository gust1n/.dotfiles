return {
   {
      'williamboman/mason.nvim',
      config = function()
         require('mason').setup()
      end
   },
   {
      'williamboman/mason-lspconfig.nvim',
      config = function()
         require('mason-lspconfig').setup()
      end
   },
   {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      config = function()
         local tools = {}
         if vim.fn.executable('go') == 1 then
            table.insert(tools, 'gopls')
            table.insert(tools, 'gofumpt')
            table.insert(tools, 'goimports')
         end
         if vim.fn.executable('lua') == 1 then
            table.insert(tools, 'lua-language-server')
         end
         require('mason-tool-installer').setup {
            ensure_installed = tools,
            auto_update = true,
            run_on_start = true,
         }
      end
   },
   'neovim/nvim-lspconfig', -- Collection of configurations for built-in LSP client
   {
      'jose-elias-alvarez/null-ls.nvim',
      config = function()
         local null_ls = require("null-ls")
         local sources = {}
         local has_sources = false
         if vim.fn.executable('go') == 1 then
            table.insert(sources, null_ls.builtins.formatting.gofumpt)
            table.insert(sources, null_ls.builtins.formatting.goimports)
            has_sources = true
         end
         if has_sources then
            require("custom_code_actions")
            null_ls.setup({ sources = sources, debug = false })
         end
      end
   },

   'christoomey/vim-system-copy',   -- Copy to system clipboard

   'tpope/vim-fugitive',            -- Git
   'tpope/vim-commentary',          -- Smart commenting
   'tpope/vim-surround',            -- Surround movement

   'editorconfig/editorconfig-vim', -- Read .editorconfig files
   'junegunn/vim-peekaboo',         -- Peek registers

   'simeji/winresizer',             -- smart resize command

   'ibhagwan/fzf-lua',

   'joshdick/onedark.vim', -- Theme inspired by Atom

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

   -- Treesitter configuration
   -- Parsers must be installed manually via :TSInstall
   {
      'nvim-treesitter/nvim-treesitter',
      config = function()
         require('nvim-treesitter.configs').setup {
            highlight = {
               enable = true, -- false will disable the whole extension
            },
            incremental_selection = {
               enable = false,
            },
            indent = {
               enable = true,
            },
            textobjects = {
               select = {
                  enable = true,
                  lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
                  keymaps = {
                     -- You can use the capture groups defined in textobjects.scm
                     ['af'] = '@function.outer',
                     ['if'] = '@function.inner',
                     ['ac'] = '@class.outer',
                     ['ic'] = '@class.inner',
                  },
               },
               move = {
                  enable = false,
                  set_jumps = true, -- whether to set jumps in the jumplist
               },
            },
         }
      end
   },
   'nvim-treesitter/nvim-treesitter-textobjects',

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
