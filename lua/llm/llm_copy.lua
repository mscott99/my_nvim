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
    full_prompt = [[I am using you as a prompt generator. I've dumped many files for context below, and I have a specific problem. Please come up with a proposal to my problem - including the code and general approach. If writing markdown, remember the following: always use dollar signs for math environments. Single for inline, double for display, with no additional spaces inside of them. Do not forget the backslash in front of latex commands. No backup of files is ever needed, because I use git.\n\n. If all the changes are in prose in markdown files, you should not ask the llm for any technical checks. Instead, state explicitly that there is no need for testing. I will take care of the export myself. Even while editing prose, try to use line numbers if you can for clearer instructions.]]
      .. prompt
      ..'\n\nRelevant context from files on my computer:\n' ..qf_context
      .. [[\n\nPlease make sure that you leave no details out, and follow my requirements specifically. I know what I am doing, and you can assume that there is a reason for my arbitrary requirements.

When generating the full prompt with all of the details, keep in mind that the model you are sending this to is not as intelligent as you. It is great at very specific instructions, so please stress that they are specific. 

If the task is complex, come up with discrete steps such that the sub-llm i am passing this to can build intermediately; as to keep it on the rails. Make sure to stress that it stops for feedback at each discrete step. Steps are not needed, only make steps if it will help the llm complete the task; a single or just two steps is completely fine in the right circumstances.

In your response, give only the instructions to the sub-llm. Any content you give will be fed to the llm, and so you could confuse it by comments meant for me. After the last step (or the single step) do not leave any information that is not meant for the llm. Do not tell the llm about relevant context in files, unless it really should go and read those files (which costs tokens).
]]
  end

  vim.fn.setreg('+', full_prompt)
  vim.notify('Prompt with quickfix context copied to clipboard!', vim.log.levels.INFO)
end

-- Function to wrap text with blocks
local function wrap_with_blocks()
  local text = vim.fn.getreg('+')
  local prefix = [[]]
  local suffix = [[
You are a change implementer, you only implement the stated changes and log the possible errors. You do not deviate
from the instructions in any way. You use tools only in order to implement the changes as specified in the instructions. You can however leave suggestions for additional tool uses before terminating, but never on your own initiative. You do not read files other than the ones you have to edit.

Please review the step of the prompt above and provide feedback. Perform only basic checks, e.g., "npm test" and "npm run build" as needed. If you get an error, do not attempt to fix it. Instead, log the error and await further instructions.

I repeat, this is important. Upon getting an error, do not fix it, stop
instead. You are missing critical information in the current context.

The instructions are step-by step. After each step you should stop to await further instructions. Stop no matter what, implementing all the steps will create problems and crash the program. After each step, test if there is an easy way to test things (like a single command). I there is not, do not test anything, that is fine. Just stop and await further instructions.

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
    elseif prompt_type == 'grok_instruct' then

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
