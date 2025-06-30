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
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      -- Setup folding when LSP attaches
      local function on_attach(client, bufnr)
        if client.server_capabilities.foldingRangeProvider then
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
          vim.opt_local.foldtext = "v:lua.vim.lsp.foldtext()"
          vim.opt_local.foldenable = true
          vim.opt_local.foldlevel = 99 -- Start with all folds open
        end
      end

      -- Setup each LSP server from language configurations
      for server, config in pairs(_G.LSP_SERVERS or {}) do
        local server_config = vim.tbl_deep_extend("force", {
          capabilities = capabilities,
          on_attach = on_attach,
        }, config)

        lspconfig[server].setup(server_config)
      end
    end,
  },
}
