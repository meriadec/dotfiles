_G.global = {}

vim.cmd("colorscheme base16-material")

-- remember last used position
vim.cmd("au BufReadPost * if line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif")

-- resize panels when client is resized
vim.cmd("autocmd VimResized * :wincmd =")

-- some language options
vim.cmd("autocmd BufNewFile,BufRead *.gyp set syntax=javascript")
vim.cmd("autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx")
vim.cmd("autocmd BufNewFile,BufRead tsconfig.json set filetype=jsonc")

require("options")
require("plugins")
require("lsp")
require("mappings")
