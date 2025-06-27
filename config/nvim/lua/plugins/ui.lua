return {
   {
      "navarasu/onedark.nvim",
      opts = { style = "dark" },
   },
   {
      "junegunn/vim-peekaboo",
   },
   {
      "simeji/winresizer",
   },
   {
      "nvim-lualine/lualine.nvim",
      event = "VeryLazy",
      opts = {
         options = {
            icons_enabled = false,
            theme = "onedark",
            globalstatus = true,
            section_separators = "",
            component_separators = "",
         },
         sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff" },
            lualine_c = { "filename" },
            lualine_x = { "diagnostics", "encoding", "fileformat", "filetype" },
            lualine_y = { "progress" },
            lualine_z = { "location" },
         },
      },
   },
}
