local ding = require 'llm.llm'
M= {}
local function handle_anthropic_spec(response)
  -- Extract diff content from the response (assumes response.content[1].text structure)
  local diff_content = response.content[1].text
  show_llm_diff(diff_content)
end


-- Function to display the diff in a vertical split
local function show_llm_diff(diff_content)
  -- Get the current buffer's content
  local orig_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local orig_content = table.concat(orig_lines, '\n')

  -- Create temporary files for original content, diff, and suggested output
  local tmp_orig = vim.fn.tempname()
  local tmp_diff = vim.fn.tempname()
  local tmp_suggested = vim.fn.tempname()

  -- Write original content and diff to temp files
  vim.fn.writefile(vim.split(orig_content, '\n'), tmp_orig)
  vim.fn.writefile(vim.split(diff_content, '\n'), tmp_diff)

  -- Apply the diff using the `patch` command
  vim.fn.system(string.format('patch %s %s -o %s', tmp_orig, tmp_diff, tmp_suggested))

  -- Open the suggested content in a vertical split
  vim.cmd('vsplit ' .. tmp_suggested)

  -- Enable diff mode between the original and suggested buffers
  local orig_win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd p') -- Switch to original window
  vim.cmd('diffthis')
  vim.cmd('wincmd w') -- Switch to suggested window
  vim.cmd('diffthis')

  -- Set keymaps in the suggested buffer for accepting/rejecting changes
  local suggested_buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_keymap(suggested_buf, 'n', '<leader>a', ':diffget<CR>', { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(suggested_buf, 'n', '<leader>d', ':diffput<CR>', { noremap = true, silent = true })

  -- Clean up temporary files (optional)
  vim.fn.delete(tmp_orig)
  vim.fn.delete(tmp_diff)
  -- Note: tmp_suggested is tied to the buffer and cleaned up by Neovim when closed
end
