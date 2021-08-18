vim.g.mapleader = "-"

vim.opt.updatetime = 150

vim.opt.encoding = "utf-8"

-- full page help
vim.opt.helpheight = 99999

-- autocomplete
vim.o.completeopt = "menuone,noselect"

-- don't write empty unsaved files
vim.opt.hidden = true

-- use space to indent
vim.opt.expandtab = true

-- search matching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- vim.opt.mouse = "c"
vim.opt.wrap = false

-- always show status bar
vim.opt.laststatus = 2

-- auto reload files when changed
vim.opt.autoread = true

-- show the 80 chars column
vim.opt.colorcolumn = "80"

-- maximum number of items to show in the popup menu
vim.opt.pumheight = 10

-- tab spacing etc.
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

vim.opt.showcmd = false

-- behavior when splitting windows
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Enables 24-bit RGB color in the TUI
vim.opt.termguicolors = true

-- don't create useless files
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.wb = false

-- number of lines to keep above & below cursor when scrolling
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 1

-- show cursor line
vim.opt.cursorline = true

-- move on search
vim.opt.incsearch = true

-- show line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- prevent annoying highlight on search
vim.opt.hlsearch = false

-- show "lint" column
vim.opt.signcolumn = "yes"

-- wild menu completion
vim.opt.wildmode = "longest,full"
vim.opt.wildmenu = true

-- show blank characters
vim.opt.listchars = "tab:>-,trail:·,nbsp:%"
vim.opt.list = true
