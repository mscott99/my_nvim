return {
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-python" },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python"),
        },
      })
    end,
    keys = {
      { "<leader>dtt", ":lua require'neotest'.run.run({strategy = 'dap'})<cr>", desc = "test" },
      { "<leader>dts", ":lua require'neotest'.run.stop()<cr>",                  desc = "stop test" },
      { "<leader>dta", ":lua require'neotest'.run.attach()<cr>",                desc = "attach test" },
      { "<leader>dtf", ":lua require'neotest'.run.run(vim.fn.expand('%'))<cr>", desc = "test file" },
      { "<leader>dts", ":lua require'neotest'.summary.toggle()<cr>",            desc = "test summary" },
    },
  },
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
