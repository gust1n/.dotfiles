return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      -- Installs any missing parser in the background; a no-op once present.
      require("nvim-treesitter").install({
        "bash",
        "go",
        "gomod",
        "gosum",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "proto",
        "python",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "yaml",
      })
    end,
  },
}
