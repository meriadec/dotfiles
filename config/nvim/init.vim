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

lua require('init')
