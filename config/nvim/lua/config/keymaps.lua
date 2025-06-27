-- Centralized key mappings configuration

local M = {}

-- Basic editor mappings
local function setup_basic_mappings()
   -- Remap ctrl-c to Esc to better support LSP and other background processes
   vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })

   -- Word wrap navigation
   vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Move up (wrap-aware)" })
   vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Move down (wrap-aware)" })

   -- Clear search highlight
   vim.keymap.set("n", "<leader><cr>", "<cmd>noh<CR>", { desc = "Clear search highlight" })

   -- Insert newlines without leaving normal mode
   vim.keymap.set("n", "<leader>o", "o<Esc>k", { desc = "Insert line below" })
   vim.keymap.set("n", "<leader>O", "O<Esc>j", { desc = "Insert line above" })
end

-- File and project navigation
local function setup_navigation_mappings()
   -- FzfLua mappings
   vim.keymap.set("n", "<leader>t", "<cmd>FzfLua files<cr>", { desc = "Find files" })
   vim.keymap.set("n", "<leader>b", "<cmd>FzfLua buffers<cr>", { desc = "Find buffers" })
   vim.keymap.set("n", "<leader>f", "<cmd>FzfLua grep_project<cr>", { desc = "Grep project" })
   vim.keymap.set("v", "<leader>f", "<cmd>FzfLua grep_visual<cr>", { desc = "Grep selection" })
   vim.keymap.set("n", "<leader>p", "<cmd>FzfLua builtin<CR>", { desc = "FzfLua builtin" })

   -- File tree
   vim.keymap.set("n", "<leader>kb", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
end

-- LSP mappings (called from autocmd when LSP attaches)
function M.setup_lsp_mappings(bufnr)
   local opts = { buffer = bufnr }

   -- Navigation
   vim.keymap.set("n", "gd", function()
      vim.lsp.buf.definition()
   end, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
   vim.keymap.set(
      "n",
      "gi",
      "<cmd>FzfLua lsp_implementations<CR>",
      vim.tbl_extend("force", opts, { desc = "Go to implementation" })
   )
   vim.keymap.set(
      "n",
      "gr",
      "<cmd>FzfLua lsp_references<CR>",
      vim.tbl_extend("force", opts, { desc = "Go to references" })
   )

   -- Documentation and help
   vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover()
   end, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
   vim.keymap.set("n", "<C-k>", function()
      vim.lsp.buf.signature_help()
   end, vim.tbl_extend("force", opts, { desc = "Signature help" }))

   -- Code actions and refactoring
   vim.keymap.set("n", "<leader>r", function()
      vim.lsp.buf.rename()
   end, vim.tbl_extend("force", opts, { desc = "Rename symbol" }))
   vim.keymap.set({ "n", "v" }, "<leader>a", function()
      require("fzf-lua").lsp_code_actions()
   end, vim.tbl_extend("force", opts, { desc = "Code actions" }))

   -- Diagnostics
   vim.keymap.set("n", "<d", function()
      vim.diagnostic.jump({ count = -1 })
   end, vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
   vim.keymap.set("n", ">d", function()
      vim.diagnostic.jump({ count = 1 })
   end, vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))
   vim.keymap.set("n", "<leader>e", function()
      vim.diagnostic.open_float()
   end, vim.tbl_extend("force", opts, { desc = "Show diagnostic" }))

   -- Workspace symbols
   vim.keymap.set("n", "<leader>s", function()
      require("fzf-lua").lsp_live_workspace_symbols()
   end, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))
end

-- Diagnostic and trouble mappings
local function setup_diagnostic_mappings()
   -- Trouble
   vim.keymap.set("n", "<leader>dd", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Toggle diagnostics" })
   vim.keymap.set("n", "<leader>db", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
   vim.keymap.set("n", "<leader>ds", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Document symbols" })
   vim.keymap.set("n", "<leader>dr", "<cmd>Trouble lsp_references toggle focus=false<cr>", { desc = "LSP references" })
   vim.keymap.set("n", "<leader>dq", "<cmd>Trouble quickfix toggle<cr>", { desc = "Quickfix list" })
   vim.keymap.set("n", "dn", "<cmd>Trouble diagnostics next<cr>", { desc = "Next diagnostic" })
   vim.keymap.set("n", "dp", "<cmd>Trouble diagnostics prev<cr>", { desc = "Previous diagnostic" })
end

-- Text editing and selection
local function setup_editing_mappings()
   -- Treesitter text objects
   vim.keymap.set("n", "<c-space>", function()
      require("nvim-treesitter.incremental_selection").init_selection()
   end, { desc = "Start selection" })
   vim.keymap.set("v", "<c-space>", function()
      require("nvim-treesitter.incremental_selection").node_incremental()
   end, { desc = "Expand selection" })
   vim.keymap.set("v", "<bs>", function()
      require("nvim-treesitter.incremental_selection").node_decremental()
   end, { desc = "Shrink selection" })
end

-- UI and window management
local function setup_ui_mappings()
   -- Window resizing
   vim.keymap.set("n", "<leader>w", "<cmd>WinResizerStartResize<cr>", { desc = "Resize windows" })
end

-- Setup all mappings
local function setup_all_mappings()
   setup_basic_mappings()
   setup_navigation_mappings()
   setup_diagnostic_mappings()
   setup_editing_mappings()
   setup_ui_mappings()
end

-- Initialize mappings
setup_all_mappings()

-- Export for use in autocmds
return M
