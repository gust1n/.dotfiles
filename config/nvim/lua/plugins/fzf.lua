return {
   {
      "ibhagwan/fzf-lua",
      keys = {
         { "<leader>a", "<cmd>lua require('fzf-lua').lsp_code_actions()<cr>",   desc = "FzfLspCodeActions" },
         { "<leader>b", "<cmd>lua require('fzf-lua').buffers()<cr>",            desc = "FzfBuffers" },
         { "<leader>t", "<cmd>lua require('fzf-lua').files()<cr>",              desc = "FzfFiles" },
         { "<leader>f", "<cmd>lua require('fzf-lua').grep({ search = ''})<cr>", desc = "FzfGrep" },
         { "<leader>f", "<cmd>lua require('fzf-lua').grep_visual()<cr>",        desc = "FzFVisualGrep",    mode = "v" },
      },
   }
}
