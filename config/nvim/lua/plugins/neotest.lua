return {
   {
      "nvim-neotest/neotest",
      dependencies = {
         "nvim-neotest/nvim-nio",
         "nvim-lua/plenary.nvim",
         "antoinemadec/FixCursorHold.nvim",
         "nvim-treesitter/nvim-treesitter",
         -- Go adapter
         "fredrikaverpil/neotest-golang",
      },
      config = function()
         local neotest = require("neotest")

         -- Get adapters from language configurations
         local lang = require("config.lang")
         local adapters = {}

         -- Collect all adapters from language configs
         local neotest_configs = lang.get_neotest_adapters()
         for _, adapter_list in pairs(neotest_configs) do
            for _, adapter in ipairs(adapter_list) do
               if type(adapter) == "string" then
                  table.insert(adapters, require(adapter))
               else
                  table.insert(adapters, adapter)
               end
            end
         end

         neotest.setup({
            adapters = adapters,
            icons = {
               running = "R",
               passed = "P",
               failed = "F",
               skipped = "S",
               unknown = "U",
            },
            quickfix = {
               enabled = true,
               open = false,
            },
            output = {
               enabled = true,
               open_on_run = "short",
            },
            status = {
               enabled = true,
               signs = true,
               virtual_text = false,
            },
         })
      end,
   },
}
