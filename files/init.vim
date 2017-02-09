" ============================================================================ "
"                                                                              "
" ---------                           .vimrc                           ------- "
"                                                                              "
" ============================================================================ "


" -- Mapping {
" ==========

  let mapleader=","

  " easymotion trigger with only 1 leader
  map <Leader> <Plug>(easymotion-prefix)

  " dvorak window focus move
  nnoremap <Space> <NOP>
  nmap <silent> <Space>h :wincmd h<CR>
  nmap <silent> <Space>t :wincmd j<CR>
  nmap <silent> <Space>n :wincmd k<CR>
  nmap <silent> <Space>s :wincmd l<CR>

  " auto indent paste
  nnoremap t p=`]
  nnoremap <S-t> <S-p>=`]

  " select pasted text
  nnoremap gp `[v`]

  " select pasted text, without first line (useful for re-indenting callbacks)
  nnoremap <Leader>l `[v`]Oj

  if has("unix")
    let s:uname = system("uname -s")
    if s:uname == "Darwin\n"
      " macOS specifics
    else
      " linux specifics
    endif
  endif

" }


" -- Plugins {
" ==========

  filetype off

  call plug#begin('~/.vim/plugged')

  Plug 'itchyny/lightline.vim'
  Plug 'chriskempson/base16-vim'
  Plug 'pangloss/vim-javascript'
  Plug 'Raimondi/delimitMate'
  Plug 'SirVer/ultisnips'
  Plug '42Zavattas/vim-snippets', { 'branch': 'develop' }
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'airblade/vim-gitgutter'
  Plug 'easymotion/vim-easymotion'
  Plug 'mxw/vim-jsx'
  Plug 'mattn/emmet-vim'
  Plug 'scrooloose/nerdcommenter'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-repeat'
  Plug 'neomake/neomake'

  call plug#end()
  filetype plugin indent on

" }


" -- Aliases {
" ==========

  command Sp set paste
  command Np set nopaste

" }


" -- Display {
" ==========

  " Need explanation ?
  syntax on

  " The chosen one
  colorscheme base16-ocean
  set background=dark

  set mouse=c

  " Encoding, etc.
  set encoding=utf-8
  set termencoding=utf-8

  " Correct strange bug
  set backspace=indent,eol,start

  " Insert space characters whenever <tab> is pressed
  set expandtab

  " Number of spaces inserted when hitting <tab>
  set tabstop=2

  " Number of spaces inserted when using :retab
  set shiftwidth=2

  " Don't wrap long lines
  set nowrap

  " Always show status bar
  set laststatus=2

  " Number of lines to keep above & below cursor when scrolling
  set sidescrolloff=15
  set sidescroll=1
  " set scrolloff=8

  " Auto reload files when changed
  set autoread

  " Show the 80 chars column
  set colorcolumn=80

  " Don't create useless files
  set noswapfile
  set nobackup
  set nowb

  " Hide unsaved buffers
  set hidden

  " Show cursor line
  set cursorline

  " Move on search
  set incsearch

  " Show line numbers
  set number

  " Show infos in status bar
  set ruler

  " Prevent annoying highlight on search
  set nohlsearch

  " More intelligent searches
  set ignorecase
  set smartcase

  " Never use Ex useless mode
  nnoremap Q <ESC>

  " Show blank characters
  set listchars=tab:>-,trail:·,nbsp:%
  set list

  " Transparent bg <3
  hi Normal ctermbg=NONE

" }

" -- Opening tab completion {
" =========================

  set wildmode=longest,full
  set wildignore=*.o,*.obj,*~
  set wildignore+=*sass-cache*
  set wildignore+=*DS_Store*
  set wildignore+=*node_modules*
  set wildignore+=*ios/*
  set wildignore+=*android/*
  set wildignore+=*bower_components*
  set wildignore+=*plugins*
  set wildignore+=*platforms*
  set wildignore+=*release*
  set wildignore+=*dist*,*dist-server*,*lib*
  set wildmenu

" }


" -- Indentation by language {
" ==========================

  autocmd Filetype go setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

" }


" -- Visual helpers {
" =================

  highlight ExtraWhitespace ctermbg=red guibg=red
  match ExtraWhitespace /\s\+$/

  autocmd! BufWinEnter * Neomake
  autocmd! BufWritePost * Neomake
  autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
  autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
  autocmd InsertLeave * match ExtraWhitespace /\s\+$/
  autocmd BufWinLeave * call clearmatches()
  autocmd VimResized * :wincmd =

  " disable xml different color for closing tag
  highlight link xmlEndTag xmlTag

" }

let g:neomake_javascript_enabled_makers = ['eslint']
let g:neomake_c_enabled_makers = []


" -- Lightline {
" ============

  let g:lightline = {
  \   'colorscheme': 'jellybeans',
  \   'active': {
  \     'left': [ [ 'mode', 'paste' ], [ 'readonly', 'relativepath', 'modified' ] ],
  \     'right': [ [ 'lineinfo' ] ]
  \    },
  \   'inactive': {
  \     'left': [ ['relativepath' ] ],
  \     'right': []
  \    },
  \ }

" }


" -- Ultisnips {
" ============

  let g:UltiSnipsExpandTrigger="<tab>"
  let g:UltiSnipsJumpForwardTrigger="<tab>"
  let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" }


" -- Vim JSX {
" ==========

  let g:jsx_ext_required = 0

" }

" -- NerdCommenter {
" ================

  let g:NERDSpaceDelims = 1
  let g:NERDTrimTrailingWhitespace = 1
  let g:NERDDefaultAlign = 'left'

" }

" -- EMMET {
" ========

  let g:user_emmet_install_global = 0
  let g:user_emmet_settings = {
  \  'javascript.jsx' : {
  \      'extends' : 'jsx',
  \  },
  \}

  autocmd FileType javascript.jsx EmmetInstall

" }
