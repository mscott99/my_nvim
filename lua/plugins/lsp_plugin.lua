return {
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-python",
       'nvim-neotest/neotest-jest'},
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python"),
          require('neotest-jest')({
            jestCommand = require('neotest-jest.jest-util').getJestCommand(vim.fn.expand '%:p:h'),
            jestConfigFile = "custom.jest.config.ts",
            jest_test_discovery = true,
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),
        },
      })
    end,
    keys = {
      {"<leader>wt", "<cmd>lua require'neotest'.watch.watch()<cr>", desc = "[W]atch [T]ests"},
      { "<leader>ts", "<cmd>lua require'neotest'.summary.toggle()<cr>",            desc = "test summary" },
      { "<leader>rtt", "<cmd>lua require'neotest'.run.run()<cr>"},
      { "<leader>dtt", "<cmd>lua require'neotest'.run.run({strategy = 'dap'})<cr>", desc = "debug tests" },
      { "<leader>ts", "<cmd>lua require'neotest'.run.stop()<cr>",                  desc = "stop test" },
      { "<leader>ta", "<cmd>lua require'neotest'.run.attach()<cr>",                desc = "attach test" },
      { "<leader>tf", "<cmd>lua require'neotest'.run.run(vim.fn.expand('%'))<cr>", desc = "test file" },
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
