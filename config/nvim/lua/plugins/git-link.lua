return {
  {
    'knsh14/vim-github-link',
    config = function()
      vim.keymap.set({ 'n', 'v' }, '<Leader>l', ':GetCommitLink<CR>')
    end,
  },
}
