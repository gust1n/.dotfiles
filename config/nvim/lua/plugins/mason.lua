return {
  {
    "mason-org/mason.nvim",
    priority = 1000,
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
            package_installed = "[+]",
            package_pending = "[>]",
            package_uninstalled = "[ ]",
          },
        },
      })

      -- Auto-install missing tools with timer
      vim.defer_fn(function()
        local registry = require("mason-registry")
        registry.refresh()

        local missing_tools = {}
        for _, tool in ipairs(unique_tools) do
          if registry.has_package(tool) then
            local pkg = registry.get_package(tool)
            if not pkg:is_installed() then
              table.insert(missing_tools, tool)
            end
          else
            vim.notify("Mason: Package '" .. tool .. "' not found in registry", vim.log.levels.WARN)
          end
        end

        if #missing_tools > 0 then
          vim.notify("Mason: Installing " .. #missing_tools .. " missing tools: " .. table.concat(missing_tools, ", "))

          for _, tool in ipairs(missing_tools) do
            local pkg = registry.get_package(tool)
            pkg:install():once("closed", function()
              if pkg:is_installed() then
                vim.notify("Mason: [+] " .. tool .. " installed successfully")
              else
                vim.notify("Mason: [-] Failed to install " .. tool, vim.log.levels.ERROR)
              end
            end)
          end
        end
      end, 1000)
    end,
  },
}
