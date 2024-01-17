return {
   {
      "neovim/nvim-lspconfig", -- Collection of configurations for built-in LSP client
      dependencies = {
         "mason.nvim",
         "williamboman/mason-lspconfig.nvim",
      },
      opts = {
         -- options for vim.diagnostic.config()
         diagnostics = {
            severity_sort = true,
         },
         -- custom LSP server setup configuration
         servers = {
            lua_ls = {
               settings = {
                  Lua = {
                     diagnostics = {
                        globals = { "vim" },
                     },
                  },
               },
            },
            gopls = {
               settings = {
                  gopls = {
                     env = {
                        GOFLAGS = "-tags=replay,e2e",
                        GOPRIVATE = "github.com/einride/*,go.einride.tech/*",
                     },
                     analyses = {
                        fieldalignment = false,
                     },
                     usePlaceholders = false,
                     staticcheck = false,
                     gofumpt = false,
                     semanticTokens = true,
                  },
               },
            },
         },
      },
      config = function(_, opts)
         -- Setup global diagnostics configuration
         vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

         -- Setup individual servers
         local servers = opts.servers
         for server, server_opts in pairs(servers) do
            if server_opts then
               require("lspconfig")[server].setup(server_opts)
            end
         end
      end,
   },
   -- Hook non LSP tools into LSP engine
   {
      "nvimtools/none-ls.nvim",
      dependencies = {
         "nvim-lua/plenary.nvim",
      },
      opts = function(_, opts)
         local nls = require("null-ls")
         opts.sources = vim.list_extend(opts.sources or {}, {
            -- Go
            nls.builtins.code_actions.gomodifytags,
            nls.builtins.code_actions.impl,
         })
      end,
   },
   -- Function signature hints
   {
      "ray-x/lsp_signature.nvim",
      event = "VeryLazy",
      opts = {
         bind = true,
         hi_parameter = "IncSearch",
         hint_enable = false,
         floating_window = true,
         floating_window_above_cur_line = true,
         doc_lines = 0,
         toggle_key = "<C-k>",
      },
   },
   -- Tools installer
   {
      "williamboman/mason.nvim",
      cmd = "Mason",
      build = ":MasonUpdate",
      dependencies = {
         "williamboman/mason-lspconfig.nvim",
      },
      opts = {
         ensure_installed = {
            -- Go
            "gopls",
            "gofumpt",
            "goimports",
            "gomodifytags",
            "impl",
            -- Lua
            "lua-language-server",
            "stylua",
            -- sh
            "shfmt",
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
   -- Fancy LSP diagnostics
   {
      "folke/trouble.nvim",
      cmd = { "TroubleToggle", "Trouble" },
      opts = {
         icons = false,
         fold_open = "v", -- icon used for open folds
         fold_closed = ">", -- icon used for closed folds
         indent_lines = false, -- add an indent guide below the fold icons
         auto_open = true, -- automatically open the list when you have diagnostics
         auto_close = true, -- automatically close the list when you have no diagnostics
         auto_preview = false, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
         signs = {
            -- icons / text used for a diagnostic
            error = "error",
            warning = "warn",
            hint = "hint",
            information = "info",
         },
         use_diagnostic_signs = true, -- enabling this will use the signs defined in your lsp client
      },
      keys = {
         { "<leader>dd", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
         {
            "dn",
            function()
               if require("trouble").is_open() then
                  require("trouble").previous({ skip_groups = true, jump = true })
               else
                  local ok, err = pcall(vim.cmd.cprev)
                  if not ok then
                     vim.notify(err, vim.log.levels.ERROR)
                  end
               end
            end,
            desc = "Previous trouble/quickfix item",
         },
         {
            "dp",
            function()
               if require("trouble").is_open() then
                  require("trouble").next({ skip_groups = true, jump = true })
               else
                  local ok, err = pcall(vim.cmd.cnext)
                  if not ok then
                     vim.notify(err, vim.log.levels.ERROR)
                  end
               end
            end,
            desc = "Next trouble/quickfix item",
         },
      },
   },
}
