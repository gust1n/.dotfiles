return {
   {
      "navarasu/onedark.nvim",
      opts = {
         style = "dark",
      },
   },
   "junegunn/vim-peekaboo", -- Peek registers
   -- interactive resize
   {
      "simeji/winresizer",
      keys = {
         { "<leader>w", "<cmd>WinResizerStartResize<cr>", desc = "NvimTreeToggle" },
      },
   },
   -- Custom status line
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
         extensions = { "fzf", "nvim-tree", "trouble", "quickfix" },
         sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff" },
            lualine_c = { "filename" },
            lualine_x = {
               { "diagnostics", sources = { "nvim_workspace_diagnostic" } },
               "encoding",
               "fileformat",
               "filetype",
            },
            lualine_y = { "progress" },
            lualine_z = { "location" },
         },
         inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {},
         },
      },
   },
}
