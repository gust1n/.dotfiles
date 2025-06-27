return {
   {
      "neovim/nvim-lspconfig",
      event = { "BufReadPre", "BufNewFile" },
      dependencies = { "mason-org/mason.nvim" },
      config = function()
         -- Modern LSP capabilities
         local capabilities = vim.lsp.protocol.make_client_capabilities()
         capabilities.textDocument.completion.completionItem.snippetSupport = true
         capabilities.textDocument.completion.completionItem.resolveSupport = {
            properties = { "documentation", "detail", "additionalTextEdits" }
         }

         -- Get LSP servers from language registry
         local lang = require("config.lang")
         local servers = lang.get_lsp_servers()

         -- Setup each configured server with modern capabilities
         for server, config in pairs(servers) do
            -- Merge capabilities with user config
            local server_config = vim.tbl_deep_extend("force", {
               capabilities = capabilities,
            }, config)

            local ok, err = pcall(require("lspconfig")[server].setup, server_config)
            if not ok then
               vim.notify("Failed to setup LSP server " .. server .. ": " .. err, vim.log.levels.ERROR)
            end
         end
      end,
   },
}
