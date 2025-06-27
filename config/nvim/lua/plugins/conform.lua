return {
   {
      "stevearc/conform.nvim",
      event = "BufWritePre",
      cmd = "ConformInfo",
      dependencies = { "mason-org/mason.nvim" },
      opts = function()
         local lang = require("config.lang")
         return {
            formatters_by_ft = lang.get_formatters(),
            format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
         }
      end,
   },
}
