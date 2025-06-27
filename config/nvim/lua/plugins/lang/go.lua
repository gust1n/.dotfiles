-- go specific tab editor settings
vim.api.nvim_create_autocmd("FileType", {
   pattern = { "go", "gomod", "gowork" },
   callback = function()
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.shiftwidth = 2
      vim.opt_local.expandtab = false

      vim.opt_local.colorcolumn = "120"
   end,
})

return {
   {
      "stevearc/conform.nvim",
      dependencies = {
         {
            "mason-org/mason.nvim",
            opts = function(_, opts)
               opts.ensure_installed = opts.ensure_installed or {}
               vim.list_extend(opts.ensure_installed, { "gofumpt", "goimports", "gci", "golines" })
            end,
         },
      },
      opts = {
         formatters_by_ft = {
            go = { "goimports", "gci", "gofumpt", "golines" },
         },
         formatters = {
            goimports = {
               -- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/goimports.lua
               args = { "-srcdir", "$FILENAME" },
            },
            gci = {
               -- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/gci.lua
               args = { "write", "--skip-generated", "-s", "standard", "-s", "default", "--skip-vendor", "$FILENAME" },
            },
            gofumpt = {
               -- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/gofumpt.lua
               prepend_args = { "-extra", "-w", "$FILENAME" },
               stdin = false,
            },
            golines = {
               -- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/golines.lua
               -- NOTE: golines will use goimports as base formatter by default which can be slow.
               -- see https://github.com/segmentio/golines/issues/33
               prepend_args = { "--base-formatter=gofumpt", "--ignore-generated", "--tab-len=1", "--max-len=120" },
            },
         },
      },
   },
}
