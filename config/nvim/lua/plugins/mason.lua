return {
   {
      "mason-org/mason.nvim",
      event = "VeryLazy",
      config = function()
         -- Setup PATH for Mason binaries
         local mason_path = vim.fn.stdpath("data") .. "/mason/bin"
         local current_path = vim.env.PATH or ""
         if not string.find(current_path, mason_path, 1, true) then
            vim.env.PATH = mason_path .. ":" .. current_path
         end

         -- Get tools from language configurations
         local lang = require("config.lang")
         local ensure_installed = lang.get_mason_tools()

         -- Remove duplicates
         local seen = {}
         local unique_tools = {}
         for _, tool in ipairs(ensure_installed) do
            if not seen[tool] then
               seen[tool] = true
               table.insert(unique_tools, tool)
            end
         end

         require("mason").setup({
            ensure_installed = unique_tools,
            ui = {
               icons = {
                  package_installed = "✓",
                  package_pending = "➜",
                  package_uninstalled = "✗"
               }
            }
         })

         -- Auto-install missing tools after VimEnter
         vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
               vim.defer_fn(function()
                  local registry = require("mason-registry")
                  registry.refresh()

                  for _, tool in ipairs(unique_tools) do
                     if registry.has_package(tool) then
                        local pkg = registry.get_package(tool)
                        if not pkg:is_installed() then
                           vim.notify("Installing " .. tool .. "...")
                           pkg:install()
                        end
                     end
                  end
               end, 100)
            end,
         })
      end,
   },
}
