return {
  {
    'stevearc/conform.nvim',
    event = 'VeryLazy',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        fish = { 'fish_indent' },
        sh = { 'shfmt' },
        tex = { 'latexindent' },
        bib = { 'latexindent' },
      },
    },
    keys = { '<leader>cf' },
    config = function()
      vim.keymap.set('n', '<leader>cf', require('conform').format, { desc = '[C]onform [F]ormat current file' })
    end,
  },
}
