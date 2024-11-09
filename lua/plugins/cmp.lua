local copilot_status = true

local function toggle_copilot()
    if copilot_status then
        -- Disable Copilot
        vim.cmd('Copilot disable')
        copilot_status = false
        vim.notify("Copilot disabled", vim.log.levels.INFO)
    else
        -- Enable Copilot
        vim.cmd('Copilot enable')
        copilot_status = true
        vim.notify("Copilot enabled", vim.log.levels.INFO)
    end
end

-- Map the toggle function to a key
vim.api.nvim_create_user_command('ToggleCopilot', toggle_copilot, {})
vim.keymap.set('n', '<leader>tc', ':ToggleCopilot<CR>', { desc = '[T]oggle [C]opilot' })

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
      {
        "zbirenbaum/copilot-cmp",
        config = function ()
          require("copilot_cmp").setup()
        end
      }
    },
  },
  'abecodes/tabout.nvim',
  {
    "zbirenbaum/copilot.lua",
    enabled=false,
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = false,
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
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
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
