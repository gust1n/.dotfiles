return {
   { -- Collection of configurations for built-in LSP client
      "neovim/nvim-lspconfig",
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
   { -- Function signature hints
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
   { -- Tools installer
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
   { -- Fancy LSP diagnostics
      "folke/trouble.nvim",
      cmd = { "Trouble" },
      opts = {
         icons = {
            indent = {
               top = "│ ",
               middle = "├╴",
               last = "└╴",
               fold_open = "> ",
               fold_closed = "v ",
            },
            folder_closed = "> ",
            folder_open = "v ",
            kinds = {
               File = "□ ",
            },
         },
         auto_close = true, -- automatically close the list when you have no diagnostics
         auto_preview = false, -- automatically preview the location of the diagnostic.
      },
      keys = {
         { "<leader>dd", "<cmd>Trouble diagnostics toggle focus=false<cr>", desc = "Workspace Diagnostics (Trouble)" },
         {
            "dn",
            function()
               if require("trouble").is_open() then
                  require("trouble").prev({ skip_groups = true, jump = true })
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
