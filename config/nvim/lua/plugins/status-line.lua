-- lualine.nvim
--
-- Custom status line

return {
  'nvim-lualine/lualine.nvim',
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
      lualine_z = { 'location' },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        { 'filename', path = 1 },
      },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {},
    },
  },
}
