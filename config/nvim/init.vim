"
" -----------------------------------------------------------------------------
"                                   .vimrc
" -----------------------------------------------------------------------------

"                                  PLUGINS
"                                  =======

" filetype off
" call plug#begin('~/.vim/plugged')

" " enable native lsp support
" Plug 'neovim/nvim-lspconfig'
" Plug 'hrsh7th/nvim-compe'
" Plug 'jose-elias-alvarez/null-ls.nvim'
" Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'
" Plug 'nvim-lua/plenary.nvim'
" Plug 'ibhagwan/fzf-lua'

" " visual stuff
" Plug 'itchyny/lightline.vim'
" Plug 'chriskempson/base16-vim'
" Plug 'airblade/vim-gitgutter'
" " Plug 'w0rp/ale'
" Plug 'junegunn/fzf'
" Plug 'junegunn/fzf.vim'
" Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }

" " cursor moving / text edition
" Plug 'tpope/vim-surround'
" Plug 'tpope/vim-repeat'
" Plug 'Raimondi/delimitMate'
" Plug 'SirVer/ultisnips'
" Plug '42Zavattas/vim-snippets'
" Plug 'scrooloose/nerdcommenter'
" Plug 'mattn/emmet-vim', { 'for': ['javascript', 'typescript', 'typescript.tsx'] }

" " languages
" Plug 'pangloss/vim-javascript'
" " Plug 'prettier/vim-prettier'
" Plug 'leafgarland/typescript-vim'
" Plug 'cespare/vim-toml'
" Plug 'gutenye/json5.vim'
" Plug 'jxnblk/vim-mdx-js'
" Plug 'rust-lang/rust.vim', { 'for': 'rust' }

" call plug#end()
" filetype plugin indent on

lua require('init')


"                                  MAPPING
"                                  =======

set helpheight=99999

let mapleader="-"

" dvorak buffer navigation
nnoremap <Space> <NOP>
nmap <silent> <Space>h :wincmd h<CR>
nmap <silent> <Space>t :wincmd j<CR>
nmap <silent> <Space>n :wincmd k<CR>
nmap <silent> <Space>s :wincmd l<CR>

" reformat
" nnoremap <silent> <Leader><Leader> :Prettier<CR>

" quick command in insert mode
inoremap II <Esc>I
inoremap AA <Esc>A
inoremap OO <Esc>O

" c-p to open files
nnoremap <C-p> :Files<CR>

" c-s to save
inoremap <c-s> <Esc>:x<CR>
nnoremap <c-s> :x<CR>

" paste & select pasted text
noremap <Leader>p p`[v`]
noremap <Leader>P P`[v`]

" select line from first non-blank char to last char
nnoremap <Leader>m ^vg_

" paste mode with <C-r>
" inoremap <silent> <C-r> <C-r><C-p>

" use fzf to search inside files
" let g:fzf_layout = { 'down': '~80%' }
" nnoremap <c-f> :Find<space>
" " nnoremap <Leader>f :Find<space><C-r><C-w><cr>
" command! -bang -nargs=* Find call fzf#vim#grep(
"   \ 'rg --column --line-number --no-heading --fixed-strings --smart-case --hidden --follow --color "always" '.shellescape(<q-args>),
"   \ 1,
"   \ fzf#vim#with_preview(),
"   \ <bang>0
" \ )

" custom files preview
" command! -bang -nargs=? -complete=dir Files
"   \ call fzf#vim#files(<q-args>, <bang>0)

" grep in current project & navigate in results
" use silver searcher if possible
command -nargs=+ -complete=file -bar Grep silent! grep! "<args>" | cwindow | redraw!
nnoremap \ :Grep<SPACE>
vnoremap \ y:Grep<SPACE><C-R><C-0><CR>
nnoremap <Leader>n :cnext<CR>
nnoremap <Leader>t :cprevious<CR>
nnoremap <Leader>q :ccl<CR>
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  let g:ctrlp_use_caching = 0
endif

" indent { / [ / ( & put cursor on blank line when <Enter> inside
inoremap {<cr> {<cr>}<c-o>O
inoremap [<cr> [<cr>]<c-o>O
inoremap (<cr> (<cr>)<c-o>O

"                                  SETTINGS
"                                  ========

" different cursors based on modes
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

" need explanation ?
" syntax on

" the chosen one
let base16colorspace=256
if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
else
  colorscheme base16-zenburn
endif

set mouse=c

" show "lint" column
set signcolumn=yes

" encoding, etc.
set encoding=utf-8

" insert space characters whenever <tab> is pressed
set expandtab

" number of spaces inserted when hitting <tab>
set tabstop=2

" number of spaces inserted when using :retab
set shiftwidth=2

" don't wrap long lines
set nowrap

" always show status bar
set laststatus=2

" number of lines to keep above & below cursor when scrolling
set sidescrolloff=15
set sidescroll=1

" auto reload files when changed
set autoread

" show the 80 chars column
set colorcolumn=80

" don't create useless files
set noswapfile
set nobackup
set nowb

" hide unsaved buffers
set hidden

" show cursor line
set cursorline

" move on search
set incsearch

" show line numbers
set relativenumber
set number

" show infos in status bar
set ruler

" prevent annoying highlight on search
set nohlsearch

" more intelligent searches
set ignorecase
set smartcase

" never use Ex useless mode
nnoremap Q <ESC>

" show blank characters
set listchars=tab:>-,trail:·,nbsp:%
set list

" transparent bg
hi Normal ctermbg=NONE

" wild menu completion
set wildmode=longest,full
set wildignore=*.o,*.obj,*~
set wildignore+=*node_modules*
set wildignore+=*ios/*
set wildignore+=yarn.lock
set wildmenu

" indentation by language
autocmd BufNewFile,BufRead *.gyp set syntax=javascript
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx
autocmd BufNewFile,BufRead tsconfig.json set filetype=json5

" highlight for json5
au BufNewFile,BufRead *.json5 set filetype=javascript

" quickfix split
autocmd! FileType qf nnoremap <buffer> <leader><Enter> <C-w><Enter><C-w>L

" display extra spaces in red
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" resize panels when client is resized
autocmd VimResized * :wincmd =

" disable xml different color for closing tag
highlight link xmlEndTag xmlTag

" remember last used position
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"                               PLUGINS CONFIG
"                               ==============

" lightline
let g:lightline = {
\   'colorscheme': 'deus',
\   'active': {
\     'left': [ [ 'mode', 'paste' ], [ 'readonly', 'relativepath', 'modified' ] ],
\     'right': [ [ 'lineinfo' ], [ 'linter_warnings', 'linter_errors', 'linter_ok' ] ]
\    },
\   'inactive': {
\     'left': [ ['relativepath' ] ],
\     'right': []
\    },
\   'component_expand': {
\     'linter_warnings': 'LightlineLinterWarnings',
\     'linter_errors': 'LightlineLinterErrors',
\     'linter_ok': 'LightlineLinterOK'
\   },
\   'component_type': {
\     'linter_warnings': 'warning',
\     'linter_errors': 'error',
\     'linter_ok': 'ok'
\   },
\ }

" ultisnips
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<tab>"
" let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
" let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/vim-snippets']

" vim jsx
let g:jsx_ext_required = 0

" nerdcommenter
let g:NERDSpaceDelims = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDDefaultAlign = 'left'

" emmet
let g:user_emmet_settings = {
\ 'typescript' : {
\     'extends' : 'jsx',
\ },
\}

" fzf
" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" nvim-compe

let g:compe = {}
let g:compe.enabled = v:true
let g:compe.autocomplete = v:true
let g:compe.debug = v:false
let g:compe.min_length = 1
let g:compe.preselect = 'enable'
let g:compe.throttle_time = 80
let g:compe.source_timeout = 200
let g:compe.resolve_timeout = 800
let g:compe.incomplete_delay = 400
let g:compe.max_abbr_width = 100
let g:compe.max_kind_width = 100
let g:compe.max_menu_width = 100
let g:compe.documentation = v:true

let g:compe.source = {}
let g:compe.source.path = v:true
let g:compe.source.buffer = v:true
let g:compe.source.calc = v:true
let g:compe.source.nvim_lsp = v:true
let g:compe.source.nvim_lua = v:true
let g:compe.source.vsnip = v:true
let g:compe.source.ultisnips = v:true
let g:compe.source.luasnip = v:true
let g:compe.source.emoji = v:true
