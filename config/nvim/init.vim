" dvorak buffer navigation
nnoremap <Space> <NOP>
nmap <silent> <Space>h :wincmd h<CR>
nmap <silent> <Space>t :wincmd j<CR>
nmap <silent> <Space>n :wincmd k<CR>
nmap <silent> <Space>s :wincmd l<CR>

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

" indent { / [ / ( / > & put cursor on blank line when <Enter> inside
inoremap {<cr> {<cr>}<c-o>O
inoremap [<cr> [<cr>]<c-o>O
inoremap (<cr> (<cr>)<c-o>O

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

lua require('init')
