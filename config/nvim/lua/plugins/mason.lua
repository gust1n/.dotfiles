return {
  {
    "mason-org/mason.nvim",
    priority = 1000,
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "[+]",
            package_pending = "[>]",
            package_uninstalled = "[ ]",
          },
        },
      })

      -- Auto-install tools from language configurations
      vim.defer_fn(function()
        local registry = require("mason-registry")
        registry.refresh()

        for _, tool in ipairs(_G.MASON_TOOLS or {}) do
          if registry.has_package(tool) then
            local pkg = registry.get_package(tool)
            if not pkg:is_installed() then
              vim.notify("Mason: Installing missing '" .. tool .. "'...", vim.log.levels.INFO)
              pkg:install()
            end
          else
            vim.notify("Mason: Package '" .. tool .. "' not found", vim.log.levels.WARN)
          end
        end
      end, 1000)
    end,
  },
}
