" vim: set foldmethod=marker foldlevel=0:
" ============================================================================
" .vimrc of Joakim Gustin {{{
" ============================================================================

" Vim 8 defaults
unlet! skip_defaults_vim
silent! source $VIMRUNTIME/defaults.vim

" }}}
" ============================================================================
" VIM-PLUG BLOCK {{{
" ============================================================================

silent! if plug#begin('~/.local/share/nvim/bundle')

" Colors
Plug 'chriskempson/vim-tomorrow-theme'

" Edit
Plug 'w0rp/ale' " Linter
let g:ale_sign_column_always = 1
let g:ale_open_list = 1
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['tslint', 'tsserver'],
\}
let g:ale_fixers = {
\   'javascript': ['prettier'],
\   'typescript': ['prettier']
\}
let g:ale_fix_on_save = 1
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/vim-peekaboo'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary',        { 'on': '<Plug>Commentary' }
Plug 'itchyny/lightline.vim'
let g:lightline = {
      \ 'colorscheme': 'Tomorrow_Night',
      \ }
Plug 'tpope/vim-sleuth' " Auto detect indentation

" Browsing
Plug 'christoomey/vim-tmux-navigator'
Plug 'scrooloose/nerdtree'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Lang
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
let g:go_def_mode='gopls'
let g:go_fmt_command = "goimports"
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'honza/dockerfile.vim'
Plug 'leafgarland/typescript-vim'

call plug#end()
endif

" }}}
" ============================================================================
" BASIC SETTINGS {{{
" ============================================================================

let mapleader      = ' '
let maplocalleader = ' '

set termguicolors

colorscheme Tomorrow-Night

augroup vimrc
    autocmd!
augroup END

set noshowmode " no need to show mode when using lightline
set autoindent
set wrap "Wrap lines
set number "Show line numbers by default
set laststatus=2 "Always show the status line
set autoread "Set to auto read when a file is changed from the outside
set so=7 "Set 7 lines to the cursor - when moving vertically using j/k
set diffopt+=vertical "open diffs vertically
autocmd InsertEnter,InsertLeave * set cul!  "Indicate insert mode with cursorline
"set completeopt=longest,menuone,preview
set hidden "A buffer becomes hidden when it is abandoned
set backspace=indent,eol,start
set ignorecase smartcase " Ignore case when searching
set hlsearch "Highlight search results
set incsearch "Makes search act like search in modern browsers
set lazyredraw "Don't redraw while executing macros (good performance config)
set encoding=utf8
set ffs=unix,dos,mac "Use Unix as the standard file type
set list listchars=tab:»·,trail:·,nbsp:· "show invisible characters

" Turn backup off, since most stuff is in version control anyway
set nobackup
set nowb
set noswapfile

" 1 tab == 4 spaces
set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Folding
set foldmethod=syntax
set foldlevelstart=99 "No folds at start

" Specify the behavior when switching between buffers
try
    set switchbuf=useopen,usetab,newtab
catch
endtry

if exists('&inccommand')
    set inccommand=nosplit
endif

" }}}
" ============================================================================
" MAPPINGS {{{
" ============================================================================

" terminal mode
if has('nvim')
    :tnoremap <expr> <esc> &filetype == 'fzf' ? "\<esc>" : "\<c-\>\<c-n>"
endif

" Language client
nnoremap <silent> gd :ALEGoToDefinition<CR>
nnoremap <silent> K :ALEHover<CR>

" Let arrow keys resize window
nnoremap <silent> <Right> :call IntelligentHorizontalResize('right')<CR>
nnoremap <silent> <Left> :call IntelligentHorizontalResize('left')<CR>
nnoremap <silent> <Up> :resize -2<CR>
nnoremap <silent> <Down> :resize +2<CR>

" Move selection up/down linewise with <alt>+[jk]
nmap √ mz:m+<cr>`z
nmap ª mz:m-2<cr>`z
vmap √ :m'>+<cr>`<my`>mzgv`yo`z
vmap ª :m'<-2<cr>`>my`<mzgv`yo`z

map <leader>kb :NERDTreeToggle<CR>

" fzf
nnoremap <silent> <Leader>t :Files<CR>
nnoremap <silent> <Leader>p :Commands<CR>
nnoremap <silent> <Leader>b :Buffers<CR>
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

" Fugitive
nmap <Leader>gs :Gstatus<CR>gg<c-n>
nnoremap <Leader>gd :Gdiff<CR>

" When you press <leader>f you grep after the selected text
vnoremap <silent> <leader>f :call VisualSelection('find')<CR>
" and in normal mode we enter simply enter interactive 'find in project'
if executable('fzf')
	nnoremap <silent> <leader>f :F<CR>
endif

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>

" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" OS X inspired "settings" shortcut
nnoremap <leader>, :e ~/.config/nvim/init.vim<CR>

" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <silent> <leader>x :bp <BAR> silent! bd #<CR>

" Start external command with single bang
nnoremap ! :!

" Insert newlines without entering insert mode
nmap <leader>o o<Esc>k
nmap <leader>O O<Esc>j

" vim-commentary
map  gc  <Plug>Commentary
nmap gcc <Plug>CommentaryLine

" }}}
" ============================================================================
" FUNCTIONS & COMMANDS {{{
" ============================================================================

" Auto close omnifunc complete window when done
autocmd CompleteDone * pclose

augroup reload_vimrc
	autocmd!
	autocmd bufwritepost $MYVIMRC nested source $MYVIMRC
augroup END

" ----------------------------------------------------------------------------
" Visual Selection
" ----------------------------------------------------------------------------
function! CmdLine(str)
	exe "menu Foo.Bar :" . a:str
	emenu Foo.Bar
	unmenu Foo
endfunction
function! VisualSelection(direction) range
	let l:saved_reg = @"
	execute "normal! vgvy"

	let l:pattern = escape(@", '\\/.*$^~[]')
	let l:pattern = substitute(l:pattern, "\n$", "", "")

	if a:direction == 'b'
		execute "normal ?" . l:pattern . "^M"
	elseif a:direction == 'find'
		call CmdLine("Rg " . l:pattern . "<CR>")
	elseif a:direction == 'replace'
		call CmdLine("%s" . '/'. l:pattern . '/')
	elseif a:direction == 'f'
		execute "normal /" . l:pattern . "^M"
	endif

	let @/ = l:pattern
	let @" = l:saved_reg
endfunction

" Be aware of whether you are right or left vertical split
" so you can use arrows more naturally.
" Inspired by https://github.com/ethagnawl.
function! IntelligentHorizontalResize(direction) abort
	let l:window_resize_count = 5
	let l:current_window_is_last_window = (winnr() == winnr('$'))

	if (a:direction ==# 'left')
		let [l:modifier_1, l:modifier_2] = ['+', '-']
	else
		let [l:modifier_1, l:modifier_2] = ['-', '+']
	endif

	let l:modifier = l:current_window_is_last_window ? l:modifier_1 : l:modifier_2
	let l:command = 'vertical resize ' . l:modifier . l:window_resize_count . '<CR>'
	execute l:command
endfunction
" }}}
