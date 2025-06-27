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
      cmd = "Trouble",
      config = function()
         require("trouble").setup({
            signs = {
               error = "E",
               warning = "W",
               hint = "H",
               information = "I",
               other = "?"
            }
         })
      end,
   },
}
