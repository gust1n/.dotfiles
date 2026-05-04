return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({
        auto_install = true,
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
    end,
  },
}
