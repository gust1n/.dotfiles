-- Language configuration helper
-- Provides utilities for setting up language-specific configurations including
-- file type settings, LSP servers, and formatters in a centralized way.
local M = {}

-- Setup filetype-specific editor settings
-- @param filetypes: table - List of filetypes to apply settings to
-- @param opts: table - Options: { indent = number, expandtab = boolean, colorcolumn = number }
function M.setup_filetype(filetypes, opts)
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

-- Register LSP server configuration
-- @param server: string - LSP server name (e.g., "lua_ls", "gopls")
-- @param config: table - LSP server configuration
-- @param mason_name: string|nil - Mason package name if different from server name
--                                 (e.g., "lua-language-server" for "lua_ls")
function M.lsp(server, config, mason_name)
  -- Store LSP config for later setup
  M._lsp_servers = M._lsp_servers or {}
  M._lsp_servers[server] = config

  -- Add Mason package to ensure_installed list
  -- Note: LSP server names != Mason package names (e.g., lua_ls != lua-language-server)
  M._mason_tools = M._mason_tools or {}
  table.insert(M._mason_tools, mason_name or server)
end

-- Register formatters for filetypes
-- @param filetypes: table - List of filetypes to apply formatters to
-- @param formatters: table - List of formatter names in order of preference
-- @param tools: table|nil - List of Mason packages to install for these formatters
function M.formatters(filetypes, formatters, tools)
  -- Store formatters for later setup
  M._formatters = M._formatters or {}
  for _, ft in ipairs(filetypes) do
    M._formatters[ft] = formatters
  end

  -- Add tools to mason ensure_installed
  if tools then
    M._mason_tools = M._mason_tools or {}
    vim.list_extend(M._mason_tools, tools)
  end
end

-- Register neotest adapters for filetypes
-- @param filetypes: table - List of filetypes to apply adapters to
-- @param adapters: table - List of neotest adapter configurations
-- @param tools: table|nil - List of Mason packages to install for these adapters
function M.neotest(filetypes, adapters, tools)
  -- Store neotest adapters for later setup
  M._neotest_adapters = M._neotest_adapters or {}
  for _, ft in ipairs(filetypes) do
    M._neotest_adapters[ft] = adapters
  end

  -- Add tools to mason ensure_installed
  if tools then
    M._mason_tools = M._mason_tools or {}
    vim.list_extend(M._mason_tools, tools)
  end
end

-- Get all registered LSP servers
function M.get_lsp_servers()
  return M._lsp_servers or {}
end

-- Get all registered formatters
function M.get_formatters()
  return M._formatters or {}
end

-- Get all mason tools to install
function M.get_mason_tools()
  return M._mason_tools or {}
end

-- Get all registered neotest adapters
function M.get_neotest_adapters()
  return M._neotest_adapters or {}
end

return M
