-- Simple language configuration system
-- Language files directly populate these global tables

-- Initialize global configuration tables
_G.LSP_SERVERS = _G.LSP_SERVERS or {}
_G.FORMATTERS = _G.FORMATTERS or {}
_G.LINTERS = _G.LINTERS or {}
_G.NEOTEST_ADAPTERS = _G.NEOTEST_ADAPTERS or {}
_G.NEOTEST_DEPENDENCIES = _G.NEOTEST_DEPENDENCIES or {}
_G.MASON_TOOLS = _G.MASON_TOOLS or {}

-- Helper function to add Mason tools
function add_mason_tools(tools)
  for _, tool in ipairs(tools) do
    if not vim.tbl_contains(_G.MASON_TOOLS, tool) then
      table.insert(_G.MASON_TOOLS, tool)
    end
  end
end

-- Helper function to add neotest adapter (handles both require and dependency)
function add_neotest_adapter(adapter_name, dependency_name)
  table.insert(_G.NEOTEST_ADAPTERS, adapter_name)
  if not vim.tbl_contains(_G.NEOTEST_DEPENDENCIES, dependency_name) then
    table.insert(_G.NEOTEST_DEPENDENCIES, dependency_name)
  end
end

-- Helper function to set up filetype settings
function setup_filetype(filetypes, opts)
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
    end,
  })
end
