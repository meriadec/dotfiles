-- vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()

  local config = function(name)
      return string.format("require('plugins.%s')", name)
  end

  -- use({ "wbthomason/packer.nvim", opt = true })
  use 'wbthomason/packer.nvim'

  -- basics
  use 'chriskempson/base16-vim'
  use 'itchyny/lightline.vim'
  use 'scrooloose/nerdcommenter'

  -- autopairs
  use {
    'windwp/nvim-autopairs',
    config = config('autopairs')
  }

  -- completion
  use {
    'hrsh7th/nvim-compe',
    config = config('compe')
  }

  -- gitsigns
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('gitsigns').setup()
    end
  }

  -- emmet
  use {
    "mattn/emmet-vim",
    ft = {
      'javascript',
      'typescript.tsx',
    },
  }

  -- lsp
  use 'neovim/nvim-lspconfig'
  use 'jose-elias-alvarez/null-ls.nvim'
  use 'jose-elias-alvarez/nvim-lsp-ts-utils'
  use 'mfussenegger/nvim-lsp-compl'

  -- treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = config("treesitter"),
  }

  -- fzf
  use({
    "ibhagwan/fzf-lua",
    requires = { "vijaymarupudi/nvim-fzf" },
    config = config('fzf'),
  })

end)

-- vim.cmd [[packadd packer.nvim]]

-- return require('packer').startup(function()
--   use "wbthomason/packer.nvim"
--   -- use({ "wbthomason/packer.nvim", opt = true })


--   use({
--     "ibhagwan/fzf-lua",
--     requires = { "vijaymarupudi/nvim-fzf" },
--     config = require('plugins/fzf'),
--   })

--   use({
--     "mattn/emmet-vim",
--     ft = {
--       'javascript',
--       'typescript.tsx',
--     },
--   })

--   -- theme

--   -- status bar

--   -- lsp
--   use 'neovim/nvim-lspconfig'
--   use 'jose-elias-alvarez/null-ls.nvim'
--   use 'jose-elias-alvarez/nvim-lsp-ts-utils'
--   use 'mfussenegger/nvim-lsp-compl'

--   -- fzf
--   use 'junegunn/fzf'
--   use 'junegunn/fzf.vim'

-- end)
