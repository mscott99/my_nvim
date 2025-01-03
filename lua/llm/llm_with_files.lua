local ding = require 'llm.llm'

M = {}
function M.get_zettel_prompt_with_quickfix(opts)
  local items = vim.fn.getqflist() -- 0: current quickfix list

  if not items or #items == 0 then
    vim.notify('Quickfix list is empty!', vim.log.levels.WARN)
    return
  end

  -- Initialize the content array with the initial prompt
  local prompt = 'I will write the content of many notes from my obsidian vault, and then tell you what I want afterwards\n'
  -- Change everything to a single prompt.
  -- Iterate through each Quickfix entry
  for _, entry in ipairs(items) do
    local file = entry.text

    -- Extract title from filename
    local title = vim.fn.fnamemodify(file, ":t:r")
    if not title or title == '' then
      title = 'Untitled Document'
    end

    -- Read file content
    local ok, file_contents = pcall(vim.fn.readfile, file)
    if not ok then
      vim.notify('Failed to read file: ' .. file, vim.log.levels.ERROR)
      goto continue -- Skip to the next file
    end
    -- Concatenate the file contents into a single string
    local file_text = table.concat(file_contents, '\n')
    local ext = file:match '^.+%.(.+)$'
    local media_type = M.get_media_type(ext)
    -- Append the title as a text object
    prompt = prompt .. "\n\n-- NEXT FILE --\ntype:Obsidian markdown\ntitle:"
    prompt = prompt .. title .."\n\ncontent:\n"..file_text
    ::continue::
  end
  prompt = prompt .. "\n\n-- MAIN PROMPT --\n\n"
  prompt = prompt .. ding.get_prompt(opts)

  return {
    {
      role = 'user',
      content = prompt,
    },
  }
end

-- Helper Function: get_media_type
function M.get_media_type(extension)
  local media_types = {
    pdf = 'application/pdf',
    md = 'text/plain',
    txt = 'text/plain',
    jpg = 'image/jpeg',
    jpeg = 'image/jpeg',
    png = 'image/png',
    gif = 'image/gif',
    -- Add more mappings as needed
  }

  return media_types[extension:lower()] or 'text/plain'
end

-- Create a Neovim command to execute the create_claude_prompt function
vim.api.nvim_create_user_command('ZettleClaude', function()
  M.create_claude_prompt()
end, {})

return M
