return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("conform").setup({
        formatters_by_ft = _G.FORMATTERS or {},
        format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
      })
    end,
  },
}
