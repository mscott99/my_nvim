-- Define the function in a suitable location (e.g., in your init.lua or a plugin file)
local function copy_with_qf_context(prompt)
  local qf_context = require('model.util.qflist').get_text()
  local full_prompt = prompt
  if qf_context ~= '' then
    full_prompt = prompt .. '\n\nRelevant context from files on my computer:\n' .. qf_context
  end

  vim.fn.setreg('+', full_prompt)
  vim.notify('Prompt with quickfix context copied to clipboard!', vim.log.levels.INFO)
end

local function grok_prompt(prompt)
  local qf_context = require('model.util.qflist').get_text()
  local full_prompt = prompt
  if qf_context ~= '' then
    full_prompt = [[I am using you as a prompt generator. I've dumped the entire context of my code base below, and I have a specific problem. Please come up with a proposal to my problem - including the code and general approach.\n\n]]
      .. prompt
      .. [[\n\nPlease make sure that you leave no details out, and follow my requirements specifically. I know what I am doing, and you can assume that there is a reason for my arbitrary requirements.

When generating the full prompt with all of the details, keep in mind that the model you are sending this to is not as intelligent as you. It is great at very specific instructions, so please stress that they are specific. 

Come up with discrete steps such that the sub-llm i am passing this to can build intermediately; as to keep it on the rails. Make sure to stress that it stops for feedback at each discrete step.]]
      ..'\n\nRelevant context from files on my computer:\n' ..qf_context
  end

  vim.fn.setreg('+', full_prompt)
  vim.notify('Prompt with quickfix context copied to clipboard!', vim.log.levels.INFO)
end

-- Function to wrap text with blocks
local function wrap_with_blocks()
  local text = vim.fn.getreg('+')
  local prefix = [[]]
  local suffix = [[
## Feedback request
Please review the step of the prompt above and provide feedback. Check with "npm test" and "npm run build". If you get an error, do not attempt to fix it. Instead, log the error and await further instructions.

I repeat, this is important. Upon getting an error, do not fix it, stop
instead. You are missing critical information in the current context.

Once approved, I'll proceed with generating the next step's output, continuing this process until all steps are complete. 
]]
  -- Concatenate the text with prefix and suffix
  local wrapped = prefix .. text .. suffix
  
  vim.fn.setreg('+', wrapped)
  vim.notify('Text wrapped and copied to clipboard!', vim.log.levels.INFO)
end

-- Create a Neovim command to wrap text with blocks
vim.api.nvim_create_user_command(
  'WrapGrok',
  function()
    wrap_with_blocks()
  end,
  {}
)


-- vim.api.nvim_create_user_command(
--   'MC',
--   function(opts)
--     copy_with_qf_context(opts.args)
--   end,
--   { nargs = '+' } -- Takes one or more arguments
-- )

vim.api.nvim_create_user_command(
  'MC',
  function(opts)
    -- Split the arguments into type and prompt
    local args = vim.split(opts.args, ' ')
    local prompt_type = args[1]
    -- Remove the first argument (type) and join the rest as the prompt
    table.remove(args, 1)
    local prompt = table.concat(args, ' ')

    if prompt_type == 'copy' then
      copy_with_qf_context(prompt)
    elseif prompt_type == 'grok' then
      grok_prompt(prompt)
    else
      vim.notify('Invalid prompt type. Use "copy" or "grok"', vim.log.levels.ERROR)
    end
  end,
  {
    nargs = '+',
    complete = function(_, _, _)
      return { 'copy', 'grok' }
    end,
  }
)




-- Optional: Add a keybinding (uncomment and modify as needed)
-- vim.keymap.set('n', '<leader>cq', ':CopyWithQF ', { desc = 'Copy with Quickfix context' })
