return {
  'github/copilot.vim',
  config = function()
    -- remap accept completion to <C-J> because <tab> is used for normal completion (e.g LSP)
    vim.keymap.set('i', '<C-J>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
    })
    vim.g.copilot_no_tab_map = true
  end,
}
