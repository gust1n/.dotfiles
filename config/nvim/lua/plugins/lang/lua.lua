local lang = require("config.lang")

-- File type settings
lang.setup_filetype({ "lua" }, {
   indent = 2,
   expandtab = true,
   colorcolumn = 120,
})

-- LSP configuration
lang.lsp("lua_ls", {
   settings = {
      Lua = {
         diagnostics = { globals = { "vim" } },
         runtime = { version = "LuaJIT" },
         workspace = {
            checkThirdParty = false,
            library = { vim.env.VIMRUNTIME },
         },
         completion = { callSnippet = "Replace" },
         hint = {
            enable = true,
            paramType = true,
            paramName = "Disable",
            semicolon = "Disable",
            arrayIndex = "Disable",
         },
      },
   },
}, "lua-language-server") -- Mason package name differs from LSP server name (lua_ls)

-- Formatters
lang.formatters({ "lua" }, { "stylua" }, { "stylua" })

-- Language files don't return anything - they just register configuration
