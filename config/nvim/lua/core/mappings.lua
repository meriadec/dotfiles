-- dvorak buffer navigation
vim.cmd("nnoremap <Space> <NOP>")
vim.cmd("nmap <silent> <Space>h :wincmd h<CR>")
vim.cmd("nmap <silent> <Space>t :wincmd j<CR>")
vim.cmd("nmap <silent> <Space>n :wincmd k<CR>")
vim.cmd("nmap <silent> <Space>s :wincmd l<CR>")

local utils = require("utils")

utils.imap("<c-c>", "<Esc>") -- remap c-c to esc
utils.imap("<c-f>", "<Esc>:Format<CR>i") -- reformat (on insert mode)
utils.imap("<c-s>", "<Esc>:x<CR>") -- c-s to save (normal mode)
utils.imap("AA", "<Esc>A") -- quick command in insert mode: go to line end
utils.imap("II", "<Esc>I") -- quick command in insert mode: go to line start
utils.imap("OO", "<Esc>O") -- quick command in insert mode: go to line above
utils.nmap("<C-p>", ":FzfLua files<CR>") -- c-p to open files
utils.nmap("<Leader><Leader>", ":Format<CR>") -- reformat
utils.nmap("<Leader>P", "P`[v`]") -- paste & select pasted text (before)
utils.nmap("<Leader>f", ":FzfLua grep_cword<CR>") -- fzf grep the current word
utils.nmap("<Leader>m", "^vg_o") -- select all line content
utils.nmap("<Leader>o", ":Bonly<CR>") -- close all buffers except the current one
utils.nmap("<Leader>p", "p`[v`]") -- paste & select pasted text (after)
utils.nmap("<c-f>", ":FzfLua live_grep<CR>") -- fzf live grep
utils.nmap("<c-s>", ":x<CR>") -- c-s to save (insert mode)
utils.nmap("Q", "<ESC>") -- never use Ex useless mode
