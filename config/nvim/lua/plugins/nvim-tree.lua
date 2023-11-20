return {
   'kyazdani42/nvim-tree.lua',
   cmd = "NvimTreeToggle",
   keys = {
      { "<leader>kb", "<cmd>NvimTreeToggle<cr>", desc = "NvimTreeToggle" },
   },
   config = {
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
}
