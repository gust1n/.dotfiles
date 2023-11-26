return {
   {
      'neovim/nvim-lspconfig', -- Collection of configurations for built-in LSP client
      -- This is due to some weird mod_cache issue introduced in
      -- https://github.com/neovim/nvim-lspconfig/commit/9a2cc569c88662fa41d414bdb65b13ea72349f86
      commit = '80861dc087982a6ed8ba91ec4836adce619f5a8a',
   },
   -- function signature hints
   {
      'ray-x/lsp_signature.nvim',
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
   -- tools installer
   {
      "williamboman/mason.nvim",
      cmd = "Mason",
      build = ":MasonUpdate",
      dependencies = {
         "williamboman/mason-lspconfig.nvim",
      },
      opts = {
         ensure_installed = {
            "stylua",
            "shfmt",
            -- "flake8",
         },
      },
      config = function(_, opts)
         require("mason").setup(opts)
         local mr = require("mason-registry")
         local function ensure_installed()
            for _, tool in ipairs(opts.ensure_installed) do
               local p = mr.get_package(tool)
               if not p:is_installed() then
                  p:install()
               end
            end
         end
         if mr.refresh then
            mr.refresh(ensure_installed)
         else
            ensure_installed()
         end
      end,
   },
   -- fancy LSP diagnostics
   {
      "folke/trouble.nvim",
      opts = {
         position = "bottom",
         icons = false,
         fold_open = "v",         -- icon used for open folds
         fold_closed = ">",       -- icon used for closed folds
         indent_lines = false,    -- add an indent guide below the fold icons
         auto_open = true,        -- automatically open the list when you have diagnostics
         auto_close = true,       -- automatically close the list when you have no diagnostics
         auto_preview = false,    -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
         signs = {
            -- icons / text used for a diagnostic
            error = "error",
            warning = "warn",
            hint = "hint",
            information = "info"
         },
         use_diagnostic_signs = true    -- enabling this will use the signs defined in your lsp client
      }
   },
}
