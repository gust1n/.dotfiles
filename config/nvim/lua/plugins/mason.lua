return {
   {
      "williamboman/mason.nvim",
      dependencies = {
         "williamboman/mason-lspconfig.nvim",
      },
      config = function()
         require('mason').setup()
         local tools = {}
         if vim.fn.executable('go') == 1 then
            table.insert(tools, 'gopls')
            -- table.insert(tools, 'gofumpt')
            -- table.insert(tools, 'goimports')
         end
         if vim.fn.executable('lua') == 1 then
            table.insert(tools, 'lua-language-server')
         end
         require('mason-lspconfig').setup {
            ensure_installed = tools,
         }
      end
   },
}
