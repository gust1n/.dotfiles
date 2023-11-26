return {
   "RRethy/nvim-base16",    -- Color scheme
   'junegunn/vim-peekaboo', -- Peek registers
   -- interactive resize
   {
      'simeji/winresizer',
      keys = {
         { "<leader>w", "<cmd>WinResizerStartResize<cr>", desc = "NvimTreeToggle" },
      },
   },
   -- Custom status line
   {
      'nvim-lualine/lualine.nvim',
      event = "VeryLazy",
      opts = {
         options = {
            icons_enabled = false,
            theme = 'onedark',
            globalstatus = true,
            section_separators = '',
            component_separators = ''
         },
         sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch', 'diff' },
            lualine_c = { 'filename' },
            lualine_x = { 'diagnostics', 'encoding', 'fileformat', 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' }
         },
         inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { 'filename' },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {}
         },
      }
   }
}
