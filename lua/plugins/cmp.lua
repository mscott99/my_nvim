return {
  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    lazy = false,
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
  },
  'abecodes/tabout.nvim',
  {
    "zbirenbaum/copilot.lua",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<c-a>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
      })
    end,
  },
  -- {
  --   'zbirenbaum/copilot-cmp',
  --   enabled = false,
  --   dependencies = {
  --     'zbirenbaum/copilot.lua',
  --   },
  -- },
}
