return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      local lspconfig = require("lspconfig")

      -- Basic capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = { "documentation", "detail", "additionalTextEdits" },
      }

      -- Setup each LSP server from language configurations
      for server, config in pairs(_G.LSP_SERVERS or {}) do
        local server_config = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
        }, config)

        lspconfig[server].setup(server_config)
      end
    end,
  },
}
