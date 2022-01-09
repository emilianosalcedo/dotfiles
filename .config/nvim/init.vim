"===============================================================================
"" -- GENERAL ------------------------------------------------------------------
"===============================================================================

set nocompatible                " Don't behave like vi
set encoding=utf-8               " Use utf8 as internal encoding
set number                      " Show line numbers
set relativenumber              " Show line number relative to the cursor
set display+=lastline           " Always display the last line of the screen
set laststatus=2                " Wider status line
set showcmd                     " Show command on the bottom
set wildmenu                    " Enhanced command line completion
set wildmode=longest,list,full  " Enable autocompletion
set visualbell                  " Use colour blink instead of sound
set cursorline                  " Highlight the cursor line
set cursorcolumn                " Highlight the column line
set colorcolumn=80              " Line length marker
set syntax=on                   " Syntax highlighting
set showmatch                   " When inserting brackets, highlight the matching one
set hlsearch                    " Highlight search results
set incsearch                   " Highlight search results as the search is typed
set ruler                       " Show line and cursor position
set tabstop=2                   " Tab equals x spaces
set expandtab                   " Expand tabs into spaces
set autoindent                  " Autoindentation
set shiftwidth=2                " x Spaces when using >
set softtabstop=2               " Fine tunes the amount of white space to be added
set nrformats+=alpha            " Incremental
set lazyredraw                  " Speed macros by not redrawing screen
set showmode
"set hidden
set background=dark
set splitbelow
set splitright
set modelines=0
set nomodeline
set scrolloff=5
set omnifunc=syntaxcomplete#Complete
filetype plugin indent on
filetype plugin on
highlight ColorColumn ctermbg=yellow

"===============================================================================
"" -- MAPPINGS -----------------------------------------------------------------
"===============================================================================

let mapleader = ";"

" Misc
set pastetoggle=<F2>
map ,n :NERDTreeToggle<CR>
map ,g :Goyo<CR>
map <leader>a :bn<CR>
map <leader>b :bp<CR>
map ,i gg=G<C-o><C-o>
noremap ,r :source ~/.vimrc<CR>
noremap % v%
noremap ,l :noh<CR>
noremap ,m :w !md-preview.sh<CR>
nnoremap ,s :%s///g<Left><Left><Left>
nnoremap ,S :!clear && shellcheck %<CR>
nnoremap ,a <C-a>
nnoremap ,x <C-x>

" Pairs
inoremap {      {}<Left>
inoremap [      []<Left>
inoremap (      ()<Left>
"inoremap "      ""<Left>
"inoremap <      <><Left>
"inoremap '      ''<Left>

" Tabs
nnoremap th  :tabfirst<CR>
nnoremap tj  :tabnext<CR>
nnoremap tk  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnew<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>

" Splits
noremap ,H :sp<CR>
noremap ,V :vsp<CR>
nnoremap ,h :sp 
nnoremap ,v :vsp 
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>
nnoremap <C-q> <C-w><C-q>

" Copy to clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_
nnoremap  <leader>y  "+y
nnoremap  <leader>yy  "+yy

" Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

"===============================================================================
"" -- FUNCTIONS ----------------------------------------------------------------
"===============================================================================

" Remember folds
augroup remember_folds
  autocmd!
  autocmd BufWinLeave * mkview
  autocmd BufWinEnter * silent! loadview
augroup END

" Reset cursor position on file save
autocmd BufWritePre * let currPos = getpos(".")
autocmd BufWritePre * cal cursor(currPos[1], currPos[2])

" Open NERDtree if no file is specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Close vim if NERDtree is the only window
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Hide tmux and make q to quit Goyo
function! s:goyo_enter()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status off
    silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
  endif

  set noshowmode
  set noshowcmd
  set scrolloff=999
  set nocursorcolumn
  set nocursorline

  let b:quitting = 0
  let b:quitting_bang = 0
  autocmd QuitPre <buffer> let b:quitting = 1
  cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!
endfunction

function! s:goyo_leave()
  if executable('tmux') && strlen($TMUX)
    silent !tmux set status on
    silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
  endif

  set showmode
  set showcmd
  set scrolloff=5
  set cursorcolumn
  set cursorline
  highlight ColorColumn ctermbg=yellow

  " Quit Vim if this is the only remaining buffer
  if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    if b:quitting_bang
      qa!
    else
      qa
    endif
  endif
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

autocmd BufRead,BufNewFile /tmp/calcurse*,~/.calcurse/notes/* set filetype=markdown

"===============================================================================
"" -- PLUGINS ------------------------------------------------------------------
"===============================================================================

" Vim Plug
"if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
"  silent !sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs
"    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
"endif

call plug#begin('~/.local/share/nvim/site/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree'
Plug 'junegunn/goyo.vim'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline_symbols_ascii = 1
let g:airline_theme='breeze'
