require("utils")

vim.g.mapleader = ","

vim.opt.completeopt = { "menuone", "noinsert" }
-- vim.opt.hidden = true
-- vim.opt.expandtab = true
-- vim.opt.ignorecase = true
-- vim.opt.mouse = "a"
-- vim.opt.pumheight = 10
-- vim.opt.shiftwidth = 4
-- vim.opt.showcmd = false
-- vim.opt.smartcase = true
-- vim.opt.splitbelow = true
-- vim.opt.splitright = true
-- vim.opt.statusline = [[%f %y %m %= %p%% %l:%c]]
-- vim.opt.tabstop = 4
-- vim.opt.termguicolors = true
-- vim.opt.undofile = true
-- vim.opt.updatetime = 300
-- vim.opt.writebackup = false
-- vim.opt.swapfile = false
-- vim.opt.directory = "/tmp"
-- vim.opt.scrolloff = 4
-- vim.opt.sidescrolloff = 2
-- vim.opt.cursorline = true
-- vim.opt.number = true
-- vim.opt.relativenumber = true
-- vim.opt.signcolumn = "yes"
-- vim.opt.timeoutlen = 300
-- vim.opt.shortmess:append("cA")
-- vim.opt.clipboard:append("unnamedplus")

_G.global = {}

-- source remaining config
-- require("commands")
require("plugins")

require("lsp")
