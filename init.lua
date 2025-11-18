vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require "setup.lazy"
require('lazy').setup("plugins")

require "opts"

require "conceals"

require "keymaps"

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

require "setup.telescope"

require "setup.quickfix"

require "setup.treesitter"

require "setup.lsp"

require "setup.cmp"

require "setup.export_obsidian"

require "setup.utils"

require "setup.obsidian"

-- require "llm.llm"

require "llm.llm_commands"

require "llm.llm_copy"

require "setup.git"

require "setup.molten"
