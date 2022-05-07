local utils = require("utils")

-- dvorak buffer navigation
utils.nmap("<Space>", "<NOP>")
utils.nmap("<Space>h", ":wincmd h<CR>")
utils.nmap("<Space>t", ":wincmd j<CR>")
utils.nmap("<Space>n", ":wincmd k<CR>")
utils.nmap("<Space>s", ":wincmd l<CR>")

-- insert mode mappings
utils.imap("<c-s>", "<Esc>:x<CR>") -- c-s to save (insert mode)
utils.imap("AA", "<Esc>A") -- quick command in insert mode: go to line end
utils.imap("II", "<Esc>I") -- quick command in insert mode: go to line start
utils.imap("OO", "<Esc>O") -- quick command in insert mode: go to line above

-- normal mode mappings
utils.nmap("<Leader><Leader>", ":Format<CR>") -- reformat
utils.nmap("<Leader>m", "^vg_o") -- select all line content
utils.nmap("<Leader>o", ":Bonly<CR>") -- close all buffers except the current one
utils.nmap("<Leader>p", "p`[v`]") -- paste & select pasted text (after)
utils.nmap("<Leader>P", "P`[v`]") -- paste & select pasted text (before)
utils.nmap("<c-s>", ":x<CR>") -- c-s to save (normal mode)
utils.nmap("Q", "<ESC>") -- never use Ex useless mode

utils.nmap("<C-p>", ":Telescope find_files theme=ivy<CR>") -- c-p to open files
utils.nmap("<c-f>", ":Telescope live_grep theme=ivy<CR>") -- live grep
utils.nmap("<Leader>f", ":Telescope grep_string theme=ivy<CR>") -- grep the current word
