-- Fuzzy finder

return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = 'master',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    local find_files_options = {
      hidden = true,
      follow = true,
      find_command = {
        'fd',
        '--type',
        'f',
        '--hidden',
        '--follow',
        '--exclude',
        '.git',
      },
      previewer = false,
    }

    require('telescope').setup {
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
      pickers = {
        find_files = find_files_options,
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require 'telescope.builtin'
    local actions = require 'telescope.actions'
    local action_state = require 'telescope.actions.state'

    vim.keymap.set('n', '<C-p>', function()
      builtin.find_files(find_files_options)
    end)
    vim.keymap.set('n', '<C-f>', builtin.live_grep)
    vim.keymap.set('n', '<leader>f', builtin.grep_string)
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics)
    vim.keymap.set('n', '<leader>sr', builtin.resume)

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    -- Shortcut to insert the path of the selected file
    local function telescope_insert_path(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      actions.close(prompt_bufnr)
      if not entry then
        return
      end

      local path = entry.path or entry.filename or entry[1]
      if not path then
        return
      end

      -- make path relative to cwd
      path = vim.fn.fnamemodify(path, ':.')

      -- insert at cursor (insert-mode friendly)
      vim.api.nvim_put({ path }, 'c', true, true)

      -- go back to insert mode
      vim.api.nvim_feedkeys('a', 'n', false)
    end

    vim.keymap.set('i', '<C-p>', function()
      builtin.find_files(vim.tbl_extend('force', find_files_options, {
        attach_mappings = function(_, map)
          map('i', '<CR>', telescope_insert_path)
          map('n', '<CR>', telescope_insert_path)
          return true
        end,
      }))
    end, { desc = 'Telescope find_files -> insert path' })
  end,
}
