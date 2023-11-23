return {
   -- Color scheme
   "RRethy/nvim-base16",
   {
      -- interactive resize
      'simeji/winresizer',
      keys = {
         { "<leader>w", "<cmd>WinResizerStartResize<cr>", desc = "NvimTreeToggle" },
      },
   },
   {
      -- nicer file tree
      'kyazdani42/nvim-tree.lua',
      cmd = "NvimTreeToggle",
      keys = {
         { "<leader>kb", "<cmd>NvimTreeToggle<cr>", desc = "NvimTreeToggle" },
      },
      opts = {
         renderer = {
            icons = {
               show = {
                  folder = false,
                  file = false,
               },
               glyphs = {
                  folder = {
                     arrow_closed = ">",
                     arrow_open = "v",
                  }
               }
            }
         },
      }
   },
}
