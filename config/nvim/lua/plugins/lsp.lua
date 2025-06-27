return {
   {
      "neovim/nvim-lspconfig",
      event = { "BufReadPre", "BufNewFile" },
      dependencies = { "mason-org/mason.nvim" },
      config = function()
         -- Get LSP servers from language registry
         local lang = require("config.lang")
         local servers = lang.get_lsp_servers()

         -- Setup each configured server
         for server, config in pairs(servers) do
            require("lspconfig")[server].setup(config)
         end
      end,
   },
   {
      "folke/trouble.nvim",
      event = "VeryLazy",
      config = function()
         require("trouble").setup()
      end,
      keys = {
         { "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>",                desc = "Diagnostics" },
         { "<leader>db", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",   desc = "Buffer Diagnostics" },
         { "<leader>ds", "<cmd>Trouble symbols toggle focus=false<cr>",        desc = "Symbols" },
         { "<leader>dr", "<cmd>Trouble lsp_references toggle focus=false<cr>", desc = "LSP References" },
         { "<leader>dq", "<cmd>Trouble quickfix toggle<cr>",                   desc = "Quickfix" },
         { "dn",         "<cmd>Trouble diagnostics next<cr>",                  desc = "Next diagnostic" },
         { "dp",         "<cmd>Trouble diagnostics prev<cr>",                  desc = "Previous diagnostic" },
      },
   },
}
