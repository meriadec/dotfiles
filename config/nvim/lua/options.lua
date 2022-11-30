-- the chosen one
vim.cmd("colorscheme nord")

-- handle tsconfig.json as jsonc
vim.cmd("autocmd BufNewFile,BufRead tsconfig.json set filetype=jsonc")

-- remember last used position when opening file
vim.cmd(
  "au BufReadPost * if line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif")

vim.g.mapleader = "-" -- leader

vim.opt.completeopt = "menuone,noselect" -- autocomplete
vim.opt.autoread = true -- auto reload files when changed
vim.opt.colorcolumn = "80" -- show the 80 chars column
vim.opt.cursorline = true -- show cursor line
vim.opt.encoding = "utf-8" -- encoding
vim.opt.expandtab = true -- use space to indent
vim.opt.helpheight = 99999 -- full page help
vim.opt.hidden = true -- don't write empty unsaved files
vim.opt.hlsearch = false -- prevent annoying highlight on search
vim.opt.ignorecase = true -- case insentitive search...
vim.opt.incsearch = true -- move on search
vim.opt.laststatus = 2 -- always show status bar
vim.opt.list = true -- show blank characters
vim.opt.listchars = "tab:>-,trail:·,nbsp:%" -- define blank characters
vim.opt.number = true -- show line numbers
vim.opt.pumheight = 10 -- maximum number of items to show in the popup menu
vim.opt.relativenumber = true -- relative line numbers
vim.opt.scrolloff = 5 -- number of lines to keep above & below cursor when scrolling
vim.opt.shiftwidth = 2 -- tab shiftwidth
vim.opt.sidescrolloff = 5 -- number of cols to keep above & below cursor when scrolling
vim.opt.signcolumn = "yes" -- show "lint" column
vim.opt.showmode = false -- show "lint" column
vim.opt.smartcase = true -- ...unless mixed case search
vim.opt.splitbelow = true -- behavior when splitting horizontally
vim.opt.splitright = true -- behavior when splitting vertically
vim.opt.swapfile = false -- don't create useless files
vim.opt.tabstop = 2 -- tab tabstop
vim.opt.termguicolors = true
vim.opt.termguicolors = true -- Enables 24-bit RGB color in the TUI
vim.opt.updatetime = 300 -- refresh rate
vim.opt.wb = false -- don't create useless files
vim.opt.wildmenu = true -- enable wild menu
vim.opt.wildmode = "longest,full" -- wild menu completion
vim.opt.wrap = false
vim.opt.mouse = "c" -- don't try to use mouse in vim lol wtf
vim.opt.writebackup = false -- don't create useless files
