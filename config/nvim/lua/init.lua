local u = require("utils")

_G.global = {}

vim.cmd("colorscheme base16-material")

-- remember last used position
vim.cmd("au BufReadPost * if line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif")

-- resize panels when client is resized
vim.cmd("autocmd VimResized * :wincmd =")

require("options")
require("plugins")
require("lsp")

u.nmap("<Leader>m", "^vg_o")
u.nmap("<Leader><Leader>", ":LspFormatting<CR>")
