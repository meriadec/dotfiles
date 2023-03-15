vim.o.breakindent = true -- Enable break indent
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.o.hlsearch = false -- Set highlight on search
vim.o.ignorecase = true -- case insentitive search
vim.o.mouse = 'c' -- Enable mouse mode
vim.o.smartcase = true -- sensitive search as soon as a different case is used
vim.o.termguicolors = true -- term colors 
-- vim.o.undofile = true -- Save undo history
vim.o.updatetime = 5 -- Decrease update time
vim.opt.autoread = true -- auto reload files when changed
vim.opt.colorcolumn = "100" -- show the 100 chars column
vim.opt.cursorline = true -- show cursor line
vim.opt.encoding = "utf-8" -- encoding
vim.opt.expandtab = true -- use space to indent
vim.opt.hidden = true -- don't write empty unsaved files
vim.opt.hlsearch = false -- prevent annoying highlight on search
vim.opt.incsearch = true -- move on search
vim.opt.laststatus = 2 -- always show status bar
vim.opt.list = true -- show blank characters
vim.opt.listchars = "tab:>-,trail:·,nbsp:%" -- define blank characters
vim.opt.pumheight = 10 -- maximum number of items to show in the popup menu
vim.opt.relativenumber = true -- relative line numbers
vim.opt.scrolloff = 5 -- number of lines to keep above & below cursor when scrolling
vim.opt.shiftwidth = 2 -- tab shiftwidth
vim.opt.showmode = false -- show "lint" column
vim.opt.sidescrolloff = 5 -- number of cols to keep above & below cursor when scrolling
vim.opt.signcolumn = "yes" -- show "lint" column
vim.opt.splitbelow = true -- behavior when splitting horizontally
vim.opt.splitright = true -- behavior when splitting vertically
vim.opt.swapfile = false -- don't create useless files
vim.opt.tabstop = 2 -- tab tabstop
vim.opt.termguicolors = true
vim.opt.wb = false -- don't create useless files
vim.opt.wildmenu = true -- enable wild menu
vim.opt.wildmode = "longest,full" -- wild menu completion
vim.opt.wrap = false
vim.opt.writebackup = false -- don't create useless files
vim.wo.number = true -- Make line numbers default
vim.wo.signcolumn = 'yes' -- Always show sign column

-- retrieve last edited line
vim.cmd("au BufReadPost * if line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif")

-- properly highlight json5 files
vim.cmd("autocmd BufNewFile,BufRead tsconfig.json set filetype=jsonc")
