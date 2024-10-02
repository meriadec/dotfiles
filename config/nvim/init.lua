-- automatically install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = "-" -- set leader key
vim.g.maplocalleader = '-' -- set local leader key

vim.o.breakindent = true -- enable break indent
vim.o.completeopt = 'menuone,noselect' -- set completeopt to have a better completion experience
vim.o.hlsearch = false -- set highlight on search
vim.o.ignorecase = true -- case insentitive search
vim.o.mouse = 'c' -- enable mouse mode
vim.o.smartcase = true -- sensitive search as soon as a different case is used
vim.o.termguicolors = true -- term colors 
vim.o.updatetime = 1 -- decrease update time
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
vim.wo.signcolumn = 'yes' -- always show sign column

local signs = {Error = "", Warn = "", Hint = "", Info = ""}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {text = icon, texthl = hl, numhl = hl})
end

vim.cmd("au BufReadPost * if line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif") -- retrieve last edited line
vim.cmd("autocmd BufNewFile,BufRead tsconfig.json set filetype=jsonc") -- properly highlight json5 files

-- disable diagnostic on .env files
vim.cmd([[
  augroup _env
   autocmd!
   autocmd BufEnter .env lua vim.diagnostic.disable(0)
  augroup end
]])

vim.keymap.set({ 'n', 'v' }, '-', '<Nop>', { silent = true }) -- disable default behavior of '-' (because leader)

-- Dvorak buffer navigation
vim.keymap.set('n', "<Space>", "<NOP>")
vim.keymap.set('n', "<Space>h", ":wincmd h<CR>")
vim.keymap.set('n', "<Space>t", ":wincmd j<CR>")
vim.keymap.set('n', "<Space>n", ":wincmd k<CR>")
vim.keymap.set('n', "<Space>s", ":wincmd l<CR>")

-- Diagnostic navigation
vim.keymap.set('n', '<leader>N', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>n', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

vim.keymap.set('n', "<Leader><Leader>", ":Format<CR>") -- reformat
vim.keymap.set('n', "<Leader>m", "^vg_o") -- select all line content
vim.keymap.set('n', "<Leader>o", ":%bd|e#<CR>") -- close all buffers except the current one
vim.keymap.set('n', "<Leader>p", "p`[v`]") -- paste & select pasted text (after)
vim.keymap.set('n', "<Leader>P", "P`[v`]") -- paste & select pasted text (before)
vim.keymap.set('n', "Q", "<ESC>") -- never use Ex useless mode

vim.keymap.set({ 'n', 'i' }, "<c-s>", "<Esc>:x<CR>") -- c-s to save

vim.keymap.set("i", "AA", "<Esc>A") -- quick command in insert mode: go to line end
vim.keymap.set("i", "II", "<Esc>I") -- quick command in insert mode: go to line start
vim.keymap.set("i", "OO", "<Esc>O") -- quick command in insert mode: go to line above

-- save with <C-Enter>
vim.keymap.set("i", "<C-Enter>", "<C-O>:w<CR>")
vim.keymap.set("n", "<C-Enter>", ":w<CR>")

-- highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- grep command with quicklist
vim.api.nvim_command("set grepprg=rg\\ --vimgrep\\ --no-heading\\ --smart-case") -- use rg for :grep/lgrep
vim.keymap.set('n', "<M-p>", ":cprev<CR>") -- previous in quickfix list
vim.keymap.set('n', "<M-n>", ":cnext<CR>") -- next in quickfix list

-- LSP attach handler
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })
end

-- PLUGINS
-- =======

local lsp_servers = {
  'bashls',
  'efm',
  'rust_analyzer',
  'tsserver',
  'gopls',
  'tailwindcss',
}

require("lazy").setup({
  -- color scheme
  {
    "arcticicestudio/nord-vim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme nord]])
    end,
  },

  -- status line
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        icons_enabled = true,
        theme = 'nord',
        component_separators = '',
        section_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'diagnostics' },
        lualine_c = {
          { 'filename', path = 1 },
        },
        lualine_x = {},
        lualine_y = { 'branch' },
        lualine_z = { 'location' }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          { 'filename', path = 1 },
        },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
      },
    },
  },

  -- show async jobs
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    config = function()
      require('fidget').setup({})
    end
  },

  -- git signs in gutter
  { "lewis6991/gitsigns.nvim", opts = {} },

  -- emmet
  {
    "mattn/emmet-vim",
    ft = {
      'javascript',
      'javascriptreact',
      'typescript.tsx',
      'typescriptreact',
    },
  },

  -- comment lines
  {
    "numToStr/Comment.nvim",
    opts = {
      toggler = { line = '<leader>cc' },
      opleader = { line = 'cc' },
    },
  },

  -- auto pairs
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({ map_cr = true })
    end
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = function()
      local ts_install = require('nvim-treesitter.install')
      pcall(ts_install.update({ with_sync = true }))
    end,
    config = function()
      local ts_configs = require('nvim-treesitter.configs')
      ts_configs.setup({
        ensure_installed = {
          'lua',
          'python',
          'rust',
          'typescript',
          'help',
        },
        highlight = { enable = true },
        indent = { enable = false },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<c-backspace>',
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@class.outer',
            },
            goto_previous_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
            goto_previous_end = {
              ['[M'] = '@function.outer',
              ['[]'] = '@class.outer',
            },
          },
          swap = {
            enable = true,
            swap_next = {
              ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
              ['<leader>A'] = '@parameter.inner',
            },
          },
        },
      })
    end
  },
  { "nvim-treesitter/nvim-treesitter-textobjects" },

  -- fuzzy finder
  { "nvim-lua/plenary.nvim", build = 'make' },
  { "nvim-telescope/telescope-fzf-native.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    config = function()
      local telescope = require('telescope')
      local ts_builtin = require('telescope.builtin')

      pcall(telescope.load_extension, 'fzf')

      telescope.setup({
        defaults = {
          preview_cutoff = 20,
          layout_config = {
            preview_width = 0.65,
            vertical = {
              width = 0.95,
            },
            horizontal = {
              width = 0.95,
            }
          },
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      })

      vim.keymap.set('n', '<C-p>', ts_builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>f', ts_builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<C-f>', ts_builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', ts_builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    end,
  },

  -- PlantUML
  { "tyru/open-browser.vim" },
  { "weirongxu/plantuml-previewer.vim" },
  { "aklt/plantuml-syntax" },

  -- LSP
  { "lukas-reineke/lsp-format.nvim", priority = 100 },
  { "williamboman/mason.nvim", priority = 100 },
  {
    "williamboman/mason-lspconfig.nvim",
    priority = 100,
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = lsp_servers,
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    priority = 50,
    config = function()
      local lspconfig = require('lspconfig')
      local servers = {
        'rust_analyzer',
        'tsserver',
        'eslint',
        'gopls',
        'tailwindcss',
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      local prettier = {
        -- formatCommand = 'biome format --stdin-file-path=${INPUT}',
        formatCommand = 'prettierd "${INPUT}"',
        formatStdin = true,
      }

      for _, lsp in ipairs(servers) do
        if lsp == 'tsserver' then
          lspconfig[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = {"typescript", "typescriptreact", "typescript.tsx", "javascript"}
          }
        else
          lspconfig[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities,
          }
        end
      end

      lspconfig.efm.setup({
        on_attach = require("lsp-format").on_attach,
        init_options = { documentFormatting = true },
        settings = {
          languages = {
            json = { prettier },
            markdown = { prettier },
            mdx = { prettier },
            conf = { prettier },
            prisma = { prettier },
            typescript = { prettier },
            typescriptreact = { prettier },
            javascript = { prettier },
            javascriptreact = { prettier },
            yaml = { prettier },
          },
        },
      })

      lspconfig.flow.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = {"javascript", "javascriptreact"}
      })
    end
  },

  -- completion
  { "hrsh7th/cmp-nvim-lsp" },
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip.loaders.from_snipmate").load()
    end
  },
  { "saadparwaiz1/cmp_luasnip" },
  { "onsails/lspkind.nvim" },
  {
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      local lspkind = require('lspkind')
      cmp.setup({
        formatting = {
          format = lspkind.cmp_format({
            mode = 'symbol', -- show only symbol annotations
            -- maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
          })
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      })
    end
  },

  -- prisma coloration
  { "prisma/vim-prisma" }
}, opts)
