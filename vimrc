"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author:
"      Joakim Gustin
"      Based on: https://github.com/amix/vimrc/blob/master/vimrcs/basic.vim
"
" Sections:
"    -> General
"    -> Plugins
"    -> VIM user interface
"    -> Colors and Fonts
"    -> Files and backups
"    -> Text, tab and indent related
"    -> Visual mode related
"    -> Moving around, tabs and buffers
"    -> Status line
"    -> Editing mappings
"    -> vimgrep searching and cope displaying
"    -> Spell checking
"    -> Misc
"    -> Helper functions
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" To be iMproved!
set nocompatible

" Sets how many lines of history VIM has to remember
set history=500

" Enable filetype plugins
filetype plugin indent on

" Set to auto read when a file is changed from the outside
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = " "
let g:mapleader = " "

" :w!! sudo saves the file
" (useful for handling the permission-denied error)
cmap w!! w !sudo tee > /dev/null %

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins (using vim-plug)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

" List of plugins:
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-commentary'
Plug 'editorconfig/editorconfig-vim'
Plug 'isRuslan/vim-es6'
Plug 'mattn/emmet-vim'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
Plug 'junegunn/fzf.vim'
Plug 'airblade/vim-gitgutter'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'junegunn/vim-peekaboo'
Plug 'tpope/vim-repeat'
Plug 'honza/vim-snippets'
Plug 'tpope/vim-surround'
Plug 'scrooloose/syntastic'
Plug 'majutsushi/tagbar'
Plug 'wellle/tmux-complete.vim', { 'do': 'chmod +x ./sh/tmuxcomplete' }
Plug 'christoomey/vim-tmux-navigator'
Plug 'SirVer/ultisnips', { 'on': [] }

" Conditionally included plugins:
if executable('go')
	Plug 'fatih/vim-go'
endif

" Load ultisnips on first time entering insert mode
func! LoadUltisnips()
	if !exists(':UltiSnipsEdit')
		call plug#load('ultisnips')
	endif
endfunc
autocmd InsertEnter * :call LoadUltisnips()

" Color themes:
Plug 'chriskempson/base16-vim'

" Enable local plugins (if exists)
if filereadable(expand("~/.vimrc.plugins.local"))
	source ~/.vimrc.plugins.local
endif

call plug#end()

" Plugin configuration

"airline
let g:airline_powerline_fonts = 1

"gitgutter
let g:gitgutter_map_keys = 0

"fzf
nnoremap <silent> <Leader>t :Files<CR>
nnoremap <silent> <Leader>p :Commands<CR>
nnoremap <silent> <Leader>b :Buffers<CR>
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-l> <plug>(fzf-complete-line)

" vim-go
let g:go_fmt_command = "goimports"
au FileType go nmap <leader>gb <Plug>(go-build)

"vim-jsx
let g:jsx_ext_required = 0 "Also show jsx syntax in .js files

" nerdtree
" close vim if only nerdtree left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen = 1
let NERDTreeIgnore=['\.vim$', '\.git$', '\.svn$', '\~$']
map <leader>kb :NERDTreeToggle<CR>

" better key bindings for UltiSnipsExpandTrigger
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

"syntastic
let g:syntastic_check_on_open=0
let g:syntastic_go_checkers = ['golint', 'govet', 'errcheck']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }

"tmux-complete
let g:tmuxcomplete#trigger = ''
inoremap <expr> <c-x><c-t> fzf#complete(tmuxcomplete#complete(0,''))

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Indicate insert mode with cursorline
autocmd InsertEnter,InsertLeave * set cul!

" open diffs vertically
set diffopt+=vertical

" Show tabline if > 1 tabs
set showtabline=1

" Turn on the WiLd menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif

"Disable annoying scratch window (when autocompleting)
set completeopt-=preview

"Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" A buffer becomes hidden when it is abandoned
set hid

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
	set mouse=a
endif

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add a bit extra margin to the left
set foldcolumn=0

" Faster switching of modes
set ttimeoutlen=20

" Disable for security reasons (as per http://stevelosh.com/blog/2010/09/coming-home-to-vim/#making-vim-more-useful)
set modelines=0

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax enable

" Set extra options when running in GUI mode
if has("gui_running")
	set guioptions-=T
	set guioptions-=e
	set t_Co=256
	set guitablabel=%M\ %t
	set guifont=Source\ Code\ Pro\ for\ Powerline:h12
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

let base16colorspace=256
colorscheme base16-tomorrow-night

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

" Recognize *.md as markdown
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Show line numbers by default
set number
set relativenumber

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Linebreak on 500 characters
set lbr
set tw=500

set ai "Auto indent
set wrap "Wrap lines

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Folding
set foldmethod=syntax
set foldlevelstart=99		" No folds at start

let javaScript_fold=1		" JavaScript
let php_folding=1			" PHP
let sh_fold_enabled=1		" sh
let vimsyn_folding="af"		" Vim script
let xml_syntax_folding=1	" XML

""""""""""""""""""""""""""""""
" => Visual mode related
""""""""""""""""""""""""""""""
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Moving around, tabs, windows and buffers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat long lines as break lines (useful when moving around in them)
map j gj
map k gk

noremap <leader>l $
noremap <leader>h ^

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>

" Move to the next buffer
nmap <Tab> :bnext<CR>

" Move to the previous buffer
nmap <S-Tab> :bprevious<CR>

" Close the current buffer and move to the previous one
" This replicates the idea of closing a tab
nmap <silent> <leader>x :bp <BAR> silent! bd #<CR>

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
	set switchbuf=useopen,usetab,newtab
catch
endtry

" Return to last edit position when opening files (but not for commit messages)
autocmd BufReadPost *
	\ if &ft != 'gitcommit' && &ft != 'svn' && line("'\"") > 0 && line("'\"") <= line("$") |
	\   exe "normal! g`\"" |
	\ endif
" Remember info about open buffers on close
set viminfo^=%

" Let arrow keys resize window
nnoremap <silent> <Right> :call IntelligentHorizontalResize('right')<CR>
nnoremap <silent> <Left> :call IntelligentHorizontalResize('left')<CR>
nnoremap <silent> <Up> :resize -2<CR>
nnoremap <silent> <Down> :resize +2<CR>

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line
set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^

" Move a line of text using <alt>+[jk]
nmap √ mz:m+<cr>`z
nmap ª mz:m-2<cr>`z
vmap √ :m'>+<cr>`<my`>mzgv`yo`z
vmap ª :m'<-2<cr>`>my`<mzgv`yo`z

" OS X inspired "settings" shortcut
nnoremap <leader>, :e ~/.vimrc<CR>

" Exit insert mode without having to reach for <Esc>
inoremap hj <Esc>

" Start external command with single bang
nnoremap ! :!

" Insert newlines without entering insert mode
nmap <leader>o o<Esc>k
nmap <leader>O O<Esc>j

" Delete trailing white space on save, set relevant filetypes below
func! DeleteTrailingWS()
	exe "normal mz"
	%s/\s\+$//ge
	exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()

" Autosave
func! AutoSave()
	if expand("%") != '' && &buftype != "nofile" && &modified
		silent! update
	endif
endfunc
autocmd InsertLeave,TextChanged * :call AutoSave()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Find and replace, quickfix
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" When you press <leader>f you grep after the selected text
vnoremap <silent> <leader>f :call VisualSelection('find')<CR>
" and in normal mode we enter simply enter Ag (interactive)
if executable('fzf')
	nnoremap <silent> <leader>f :Ag<CR>
endif

" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace')<CR>

" Similar to :bufdo this performs a command on all files in quickfix
command! -nargs=+ QuickFixDo call QuickFixDo(<q-args>)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Misc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle paste mode on and off
map \p :setlocal paste!<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

" Function that does the work
function! QuickFixDo(command)
	" Create a dictionary so that we can get the list of buffers rather than
	" the list of lines in buffers (easy way to get unique entries)
	let buffer_numbers = {}

	" For each entry, use the buffer number as a dictionary key
	for fixlist_entry in getqflist()
		let buffer_numbers[fixlist_entry['bufnr']] = 1
	endfor

	" Make it into a list as it seems cleaner
	let buffer_number_list = keys(buffer_numbers)

	" For each buffer
	for num in buffer_number_list
		" Select the buffer
		exe 'buffer' num
		" Run the command that's passed as an argument
		exe a:command
		" Save if necessary
		update
		" Close the buffer
		bd
	endfor
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
