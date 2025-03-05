-- Define the function in a suitable location (e.g., in your init.lua or a plugin file)
local function copy_with_qf_context(prompt)
  local qf_context = require('model.util.qflist').get_text()
  local full_prompt = prompt
  if qf_context ~= '' then
    full_prompt = prompt .. 
                  '\n\nHere is relevant context from quickfix list:\n' .. 
                  qf_context
  end
  
  vim.fn.setreg('+', full_prompt)
  vim.notify('Prompt with quickfix context copied to clipboard!', vim.log.levels.INFO)
end
vim.api.nvim_create_user_command(
  'MC',
  function(opts)
    copy_with_qf_context(opts.args)
  end,
  { nargs = '+' } -- Takes one or more arguments
)

-- Optional: Add a keybinding (uncomment and modify as needed)
-- vim.keymap.set('n', '<leader>cq', ':CopyWithQF ', { desc = 'Copy with Quickfix context' })
