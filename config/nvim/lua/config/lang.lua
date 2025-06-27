-- Simplified language configuration helper
local M = {}

-- Setup filetype-specific settings
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
function M.lsp(server, config)
   -- Store config for later setup
   M._lsp_servers = M._lsp_servers or {}
   M._lsp_servers[server] = config

   -- Add to mason ensure_installed
   M._mason_tools = M._mason_tools or {}
   table.insert(M._mason_tools, server)
end

-- Register formatters
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

return M
