-- Remap ctrl-c to Esc to better support LSP and other background processes
vim.api.nvim_set_keymap("i", "<C-c>", "<Esc>", { noremap = false, silent = false })

vim.api.nvim_set_keymap("n", "<>k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })

--Remap for dealing with word wrap
vim.api.nvim_set_keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Clear highlight
vim.api.nvim_set_keymap("n", "<leader><cr>", ":noh<CR>", { noremap = true, silent = true })

-- Insert newlines without leaving normal mode
vim.api.nvim_set_keymap("n", "<leader>o", "o<Esc>k", { noremap = false, silent = false })
vim.api.nvim_set_keymap("n", "<leader>O", "O<Esc>j", { noremap = false, silent = false })
