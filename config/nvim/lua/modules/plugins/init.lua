require 'impatient'

require('packer').startup(function()

  use 'wbthomason/packer.nvim'
  use 'lewis6991/impatient.nvim'             -- improve startup time

  use 'arcticicestudio/nord-vim'             -- theme
  use "SirVer/ultisnips"                     -- snippets
  use "hrsh7th/nvim-compe"                   -- completion
  use "ibhagwan/fzf-lua"                     -- fzf
  use "itchyny/lightline.vim"                -- lightline
  use "jose-elias-alvarez/nvim-lsp-ts-utils" -- typescript lsp utils
  use "kyazdani42/nvim-web-devicons"         -- icons
  use "lewis6991/gitsigns.nvim"              -- gitsigns
  use "mfussenegger/nvim-lsp-compl"          -- lsp completion
  use "mhartington/formatter.nvim"           -- formatter
  use "neovim/nvim-lspconfig"                -- lsp configuration
  use "norcalli/nvim-colorizer.lua"          -- colorizer
  use "nvim-lua/plenary.nvim"                -- utils
  use "scrooloose/nerdcommenter"             -- line comments
  use "towolf/vim-helm"                      -- helm syntax highlight
  use "vijaymarupudi/nvim-fzf"               -- fzf
  use "windwp/nvim-autopairs"                -- autopairs
  use "jparise/vim-graphql"                  -- graphql
  use "junegunn/goyo.vim"                    -- distraction free

  -- treesitter
  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate"
  }

  -- emmet
  use {
    "mattn/emmet-vim",
    ft = { 'javascript', 'typescript.tsx', 'typescriptreact' }
  }

end)
