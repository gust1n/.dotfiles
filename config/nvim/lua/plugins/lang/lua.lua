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
      diagnostics = {
        globals = { "vim", "describe", "it", "before_each", "after_each" },
      },
      runtime = {
        version = "LuaJIT",
        path = vim.list_extend(vim.split(package.path, ";"), {
          "lua/?.lua",
          "lua/?/init.lua",
        }),
      },
      workspace = {
        checkThirdParty = false,
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.stdpath("config"),
          vim.fn.stdpath("data") .. "/lazy",
          "${3rd}/luv/library",
        },
      },
      completion = { callSnippet = "Replace" },
      hint = {
        enable = true,
        paramType = true,
        paramName = "Disable",
        semicolon = "Disable",
        arrayIndex = "Disable",
      },
      telemetry = { enable = false },
    },
  },
}, "lua-language-server") -- Mason package name differs from LSP server name (lua_ls)

-- Formatters
lang.formatters({ "lua" }, { "stylua" }, { "stylua" })

-- Language files don't return anything - they just register configuration
