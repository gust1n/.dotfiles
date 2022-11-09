-- Install packer (if not done already)
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

vim.cmd [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]]

-- Config that need to be before packer

local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Inception

  use 'williamboman/mason.nvim' -- Installer for LSPs, linters etc
  use 'williamboman/mason-lspconfig.nvim' 
  use 'WhoIsSethDaniel/mason-tool-installer.nvim'
  use 'neovim/nvim-lspconfig' -- Collection of configurations for built-in LSP client
  use 'jose-elias-alvarez/null-ls.nvim' -- Plug into the Language Server with other tools

  use 'christoomey/vim-system-copy' -- Copy to system clipboard

  use 'RRethy/vim-illuminate' -- Highlight word under cursor

  use 'tpope/vim-fugitive' -- Git
  use 'tpope/vim-commentary' -- Smart commenting
  use 'tpope/vim-surround' -- Surround movement

  use 'editorconfig/editorconfig-vim' -- Read .editorconfig files
  use 'junegunn/vim-peekaboo' -- Peek registers

  use 'simeji/winresizer' -- smart resize command

  use { 'ibhagwan/fzf-lua',
    -- optional for icon support
    requires = { 'kyazdani42/nvim-web-devicons' }
  }

  use 'joshdick/onedark.vim' -- Theme inspired by Atom
  -- use 'itchyny/lightline.vim' -- Fancier statusline
  use'nvim-lualine/lualine.nvim'-- Fancier statusline

  use { 'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' } } -- Git signs in sign column

  use 'nvim-treesitter/nvim-treesitter'
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  use 'ray-x/lsp_signature.nvim'
  use 'nvim-lua/popup.nvim'
  use 'christoomey/vim-tmux-navigator'
  use {
	  "folke/trouble.nvim",
	  requires = "kyazdani42/nvim-web-devicons",
	  config = function()
		  require("trouble").setup {
			  position = "bottom",
			  -- icons = false,
			  -- fold_open = "v", -- icon used for open folds
			  -- fold_closed = ">", -- icon used for closed folds
			  -- indent_lines = false, -- add an indent guide below the fold icons
			  auto_open = true, -- automatically open the list when you have diagnostics
			  auto_close = true, -- automatically close the list when you have no diagnostics
		          auto_preview = false, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
			  -- signs = {
				  -- -- icons / text used for a diagnostic
				  -- error = "error",
				  -- warning = "warn",
				  -- hint = "hint",
				  -- information = "info"
			  -- },
			  -- use_diagnostic_signs = true -- enabling this will use the signs defined in your lsp client
		  }
	  end
  }
  use {
	  'kyazdani42/nvim-tree.lua',
	  config = function() require'nvim-tree'.setup {} end
  }
end)

--Global statusline
vim.opt.laststatus = 3

-- Disable mouse
vim.opt.mouse = ""

--Set highlight on search
vim.o.hlsearch = true

--Show line numbers
vim.wo.number = true

-- Scroll when 7 lines from top/bottom
vim.wo.so = 7

--Enable break indent
vim.o.breakindent = true

--Save undo history
vim.opt.undofile = true

--Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

--Decrease update time
vim.o.updatetime = 250

-- Always show sign column
vim.wo.signcolumn = 'yes'

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 2
vim.cmd [[colorscheme onedark]]

-- fzf-lua config
require('fzf-lua').setup {
	grep = {
		rg_glob = true,
	}
}

-- lualine setup
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'onedark',
    globalstatus = true,
    section_separators = '',
    component_separators = ''
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff'},
    lualine_c = {'filename'},
    lualine_x = {'diagnostics', 'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
}

--Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.api.nvim_set_keymap('n', '<>k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })

--Remap for dealing with word wrap
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Flash selection on yank
vim.cmd [[
  augroup YankHighlight
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank()
  augroup end
]]

-- Mason
require('mason').setup()
require('mason-lspconfig').setup()
require('mason-tool-installer').setup {
  ensure_installed = {
    'gopls',
    'goimports',
  },
  auto_update = true,
  run_on_start = true,
}

-- Null LS
require("null-ls").setup({
    sources = {
	require("null-ls").builtins.formatting.goimports
    },
})

-- Gitsigns
require('gitsigns').setup {
  signs = {
    add = { hl = 'GitGutterAdd', text = '+' },
    change = { hl = 'GitGutterChange', text = '~' },
    delete = { hl = 'GitGutterDelete', text = '_' },
    topdelete = { hl = 'GitGutterDelete', text = '‾' },
    changedelete = { hl = 'GitGutterChange', text = '~' },
  },
}

--Add leader shortcuts
vim.api.nvim_set_keymap('n', '<leader>kb', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>w', ':WinResizerStartResize<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>a', [[<cmd>lua require('fzf-lua').lsp_code_actions()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>b', [[<cmd>lua require('fzf-lua').buffers()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>t', [[<cmd>lua require('fzf-lua').files()<CR>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>f', [[<cmd>lua require('fzf-lua').live_grep_native()<CR>]], { noremap = true, silent = true })

-- Clear highlight
vim.api.nvim_set_keymap('n', '<leader><cr>', ':noh<CR>', { noremap = true, silent = true })

-- Insert newlines without leaving normal mode
vim.api.nvim_set_keymap('n', '<leader>o', 'o<Esc>k', { noremap = false, silent = false })
vim.api.nvim_set_keymap('n', '<leader>O', 'O<Esc>j', { noremap = false, silent = false })


-- Treesitter configuration
-- Parsers must be installed manually via :TSInstall
require('nvim-treesitter.configs').setup {
  highlight = {
    enable = true, -- false will disable the whole extension
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  },
}

-- LSP settings

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = false,
  }
)

-- control which LSP formatting is used
local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            return client.name == "null-ls"
        end,
        bufnr = bufnr,
    })
end

-- group for enabling auto format on save
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lspconfig = require 'lspconfig'
local on_attach = function(client, bufnr)
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  if client.supports_method("textDocument/formatting") then
	  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
	  vim.api.nvim_create_autocmd("BufWritePre", {
		  group = augroup,
		  buffer = bufnr,
		  callback = function()
			  lsp_formatting(bufnr)
		  end,
	  })
  end

lspconfig.gopls.setup {
  settings = {
	  gopls = {
		  env = {
			  GOFLAGS = "-tags=emulation"
		  }
	  }
  }
}

  local opts = { noremap = true, silent = true }
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>FzfLua lsp_references<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '>d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>dq', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>dt', [[<cmd>lua require('fzf-lua').diagnostics_workspace()<CR>]], opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>p', [[<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>]], opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>s', [[<cmd>lua require('fzf-lua').lsp_live_workspace_symbols()<CR>]], opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'v', '<Leader>f', [[<cmd>lua require('fzf-lua').grep_visual()<CR>]], opts)

  -- setup function signature hints
  require "lsp_signature".on_attach({
	  bind = true,
	  hi_parameter = "IncSearch",
	  hint_enable = true,
	  floating_window = false,
  }, bufnr)
end

-- Enable the following language servers
local servers = { 'gopls', 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
  }
end
