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
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/vim-peekaboo'
Plug 'junegunn/fzf',        { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary',        { 'on': '<Plug>Commentary' }
Plug 'mbbill/undotree',             { 'on': 'UndotreeToggle'   }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'justinmk/vim-sneak'
Plug 'szw/vim-maximizer'

" Browsing
Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesEnable' }
autocmd! User indentLine doautocmd indentLine Syntax
Plug 'christoomey/vim-tmux-navigator'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'

" Git
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'

" Lang
Plug 'jodosha/vim-godebug'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'honza/dockerfile.vim'
Plug 'ternjs/tern_for_vim',        { 'do': 'npm install' }
Plug 'posva/vim-vue'

" Lint
Plug 'w0rp/ale'
let g:ale_html_tidy_options = '-q -e -language en --show-body-only yes'


call plug#end()
endif

" Plugin configuration

" airline
let g:airline#extensions#tabline#enabled = 1
" let g:airline_section_y = airline#section#create_right(['ffenc', autosaving])

" ultisnips
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" vim-go
let g:go_fmt_command = "goimports"

" sneak
let g:sneak#label = 1

" }}}
" ============================================================================
" BASIC SETTINGS {{{
" ============================================================================

let mapleader      = ' '
let maplocalleader = ' '

set termguicolors

colorscheme tomorrow-night

augroup vimrc
	autocmd!
augroup END

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

" }}}
" ============================================================================
" MAPPINGS {{{
" ============================================================================

" terminal mode
:tnoremap <Esc> <C-\><C-n>

" Let arrow keys resize window
nnoremap <silent> <Right> :call IntelligentHorizontalResize('right')<CR>
nnoremap <silent> <Left> :call IntelligentHorizontalResize('left')<CR>
nnoremap <silent> <Up> :resize -2<CR>
nnoremap <silent> <Down> :resize +2<CR>

" Move to the next buffer
nmap <Tab> :bnext<CR>

" Move to the previous buffer
nmap <S-Tab> :bprevious<CR>

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
" and in normal mode we enter simply enter Ag (interactive)
if executable('fzf')
	nnoremap <silent> <leader>f :Ag<CR>
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
" AutoSave
" ----------------------------------------------------------------------------

function! s:autosave(enable)
	augroup autosave
		autocmd!
		if a:enable
			autocmd TextChanged,InsertLeave <buffer>
						\  if empty(&buftype) && !empty(bufname(''))
						\|   silent! update
						\| endif
		endif
	augroup END
endfunction

command! -bang AutoSave call s:autosave(<bang>1)
call s:autosave(1) " enabled by default

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
		call CmdLine("Ag " . l:pattern . "<CR>")
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
