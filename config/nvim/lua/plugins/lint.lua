return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        javascript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescript = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
      }

      local function should_use_eslint()
        local cwd = vim.fn.getcwd()
        return vim.fn.filereadable(cwd .. '/.eslintrc') == 1
          or vim.fn.filereadable(cwd .. '/.eslintrc.js') == 1
          or vim.fn.filereadable(cwd .. '/.eslintrc.cjs') == 1
          or vim.fn.filereadable(cwd .. '/eslint.config.js') == 1
          or vim.fn.filereadable(cwd .. '/eslint.config.mjs') == 1
          or vim.fn.filereadable(cwd .. '/eslint.config.cjs') == 1
      end

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if not vim.opt_local.modifiable:get() then
            return
          end
          if vim.tbl_contains({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }, vim.bo.filetype) then
            if should_use_eslint() then
              lint.try_lint 'eslint_d'
            end
          else
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
