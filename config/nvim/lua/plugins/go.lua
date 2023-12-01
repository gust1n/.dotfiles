return {
   -- Ensure Go tools are installed
   {
      "williamboman/mason.nvim",
      opts = function(_, opts)
         opts.ensure_installed = opts.ensure_installed or {}
         vim.list_extend(opts.ensure_installed, { "gopls", "gofumpt", "goimports" })
      end,
   },
   {
      "nvimtools/none-ls.nvim",
      dependencies = {
         "nvim-lua/plenary.nvim",
         {
            "williamboman/mason.nvim",
            opts = function(_, opts)
               opts.ensure_installed = opts.ensure_installed or {}
               vim.list_extend(opts.ensure_installed, { "gomodifytags", "impl" })
            end,
         },
      },
      opts = function(_, opts)
         local nls = require("null-ls")
         opts.sources = vim.list_extend(opts.sources or {}, {
            nls.builtins.code_actions.gomodifytags,
            nls.builtins.code_actions.impl,
         })
      end,
   },
}
