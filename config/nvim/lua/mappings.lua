local u = require("utils")

u.nmap("<Leader>m", "^vg_o")
u.nmap("<Leader><Leader>", ":LspFormatting<CR>")

-- dvorak buffer navigation
vim.cmd("nnoremap <Space> <NOP>")
vim.cmd("nmap <silent> <Space>h :wincmd h<CR>")
vim.cmd("nmap <silent> <Space>t :wincmd j<CR>")
vim.cmd("nmap <silent> <Space>n :wincmd k<CR>")
vim.cmd("nmap <silent> <Space>s :wincmd l<CR>")

-- quick command in insert mode
u.imap("II", "<Esc>I")
u.imap("AA", "<Esc>A")
u.imap("OO", "<Esc>O")

-- c-p to open files
u.nmap("<C-p>", ":Files<CR>")

-- c-s to save
u.nmap("<c-s>", "<Esc>:x<CR>")
u.imap("<c-s>", ":x<CR>")

-- paste & select pasted text
u.nmap("<Leader>p", "p`[v`]")
u.nmap("<Leader>P", "P`[v`]")

-- indent { / [ / ( / > & put cursor on blank line when <Enter> inside
u.imap("{<cr>", "{<cr>}<c-o>O")
u.imap("[<cr>", "[<cr>]<c-o>O")
u.imap("(<cr>", "(<cr>)<c-o>O")

-- never use Ex useless mode
u.nmap("Q", "<ESC>")
