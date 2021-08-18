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
" command -nargs=+ -complete=file -bar Grep silent! grep! "<args>" | cwindow | redraw!
" nnoremap \ :Grep<SPACE>
" vnoremap \ y:Grep<SPACE><C-R><C-0><CR>
" nnoremap <Leader>n :cnext<CR>
" nnoremap <Leader>t :cprevious<CR>
" nnoremap <Leader>q :ccl<CR>
" if executable('ag')
"   set grepprg=ag\ --nogroup\ --nocolor
"   let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
"   let g:ctrlp_use_caching = 0
" endif

" indent { / [ / ( / > & put cursor on blank line when <Enter> inside
inoremap {<cr> {<cr>}<c-o>O
inoremap [<cr> [<cr>]<c-o>O
inoremap (<cr> (<cr>)<c-o>O


"                                  SETTINGS
"                                  ========

" different cursors based on modes
let &t_SI = "\<Esc>[6 q"
let &t_SR = "\<Esc>[4 q"
let &t_EI = "\<Esc>[2 q"

" never use Ex useless mode
nnoremap Q <ESC>

" indentation by language
autocmd BufNewFile,BufRead *.gyp set syntax=javascript
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx
autocmd BufNewFile,BufRead tsconfig.json set filetype=jsonc

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

lua require('init')
