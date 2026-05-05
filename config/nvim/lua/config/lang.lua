-- Language configuration helpers
-- Language files in lua/plugins/lang/ use these to register settings

_G.FORMATTERS = _G.FORMATTERS or {}
_G.LINTERS = _G.LINTERS or {}

function _G.setup_filetype(filetypes, opts)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes,
    callback = function()
      if opts.indent then
        vim.opt_local.shiftwidth = opts.indent
        vim.opt_local.tabstop = opts.indent
        vim.opt_local.softtabstop = opts.indent
      end
      if opts.expandtab ~= nil then
        vim.opt_local.expandtab = opts.expandtab
      end
      if opts.colorcolumn then
        vim.opt_local.colorcolumn = tostring(opts.colorcolumn)
      end
      if opts.textwidth then
        vim.opt_local.textwidth = opts.textwidth
      end
    end,
  })
end
