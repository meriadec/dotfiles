return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {}

      local function should_use_eslint()
        local cwd = vim.fn.getcwd()
        return vim.fn.filereadable(cwd .. '/.eslintrc') == 1
          or vim.fn.filereadable(cwd .. '/.eslintrc.js') == 1
          or vim.fn.filereadable(cwd .. '/.eslintrc.cjs') == 1
          or vim.fn.filereadable(cwd .. '/eslint.config.js') == 1
          or vim.fn.filereadable(cwd .. '/eslint.config.mjs') == 1
          or vim.fn.filereadable(cwd .. '/eslint.config.cjs') == 1
      end

      local function should_use_biome()
        local cwd = vim.fn.getcwd()
        return vim.fn.filereadable(cwd .. '/biome.json') == 1
      end

      -- Create autocommand which carries out the actual linting on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          if not vim.opt_local.modifiable:get() then
            return
          end
          if vim.tbl_contains({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }, vim.bo.filetype) then
            if should_use_eslint() then
              lint.try_lint 'eslint_d'
            elseif should_use_biome() then
              lint.try_lint 'biomejs'
            end
          else
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
