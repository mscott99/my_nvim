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
  local full_prompt = [[I am using you as a prompt generator. I've dumped many files for context below, and I have a specific problem. Please come up with a proposal to my problem - including the code and general approach. If writing markdown, remember the following: always use dollar signs for math environments. Single for inline, double for display, with no additional spaces inside of them. Do not forget the backslash in front of latex commands. No backup of files is ever needed, because I use git.\n\n. If all the changes are in prose in markdown files, you should not ask the llm for any technical checks. Instead, state explicitly that there is no need for testing. I will take care of the export myself. Even while editing prose, try to use line numbers if you can for clearer instructions.]]
    .. prompt
  if qf_context ~= '' then
    full_prompt = prompt .. '\n\nRelevant context from files on my computer:\n' .. qf_context
  end
  full_prompt = full_prompt
    .. [[\n\nPlease make sure that you leave no details out, and follow my requirements specifically. I know what I am doing, and you can assume that there is a reason for my arbitrary requirements.

When generating the full prompt with all of the details, keep in mind that the model you are sending this to is not as intelligent as you. It is great at very specific instructions, so please stress that they are specific. 

If the task is complex, come up with discrete steps such that the sub-llm i am passing this to can build intermediately; as to keep it on the rails. Make sure to stress that it stops for feedback at each discrete step. Steps are not needed, only make steps if it will help the llm complete the task; a single or just two steps is completely fine in the right circumstances. If you do make steps, at the end of each step also specify what testing functions (unit tests) the llm should write. Only require minimal testing, as it is expensive. If no testing is required, then do not ask for testing, it is fine.

In your response, give only the instructions to the sub-llm. Any content you give will be fed to the llm, and so you could confuse it by comments meant for me. After the last step (or the single step) do not leave any information that is not meant for the llm. Do not tell the llm about relevant context in files, unless it really should go and read those files (which costs tokens).
]]

  vim.fn.setreg('+', full_prompt)
  vim.notify('Prompt with quickfix context copied to clipboard!', vim.log.levels.INFO)
end

-- Function to wrap text with blocks
local function wrap_with_blocks()
  local text = vim.fn.getreg '+'
  local prefix = [[
You are a change implementer, you only implement the stated changes and log the possible errors. You are a sub-llm who follows the given detailed instructions, and you do not deviate
from the instructions in any way. You use tools only in order to implement the changes as specified in the instructions, and show no initiative in providing fixes which were not explicitly given in the instructions. If you think such initiative is necessary, instead of doing it, you terminate and explain the problem. You can leave suggestions for additional tool uses before terminating, but never on your own initiative. You do not read files other than the ones you have to edit.

Please see the instructions below.
INSTRUCTIONS:

]]
  local suffix = [[
After finishing one step, perform only basic checks, e.g., "npm test" and "npm run build" as needed. If you get an error, log the error and terminate, and await further instructions. Do NOT try to fix the error.

I repeat, this is important. Upon getting an error when testing or otherwise, do not fix it, log and stop
instead. You are missing critical information in the current context.

The instructions may be given step-by step. For you this means that you only ever perform a single step. After each step you should stop to await further instructions. Stop no matter what, because implementing all the steps at once will create problems and crash the program. At each step, test if there is an easy way to test things (like running a single command). I there is not, do not test anything, that is fine. Just stop and await further instructions.

Once a step is approved, I will prompt you for the next step, but only if you terminate at the end of a test.
]]
  -- Concatenate the text with prefix and suffix
  local wrapped = prefix .. text .. suffix

  vim.fn.setreg('+', wrapped)
  vim.notify('Text wrapped and copied to clipboard!', vim.log.levels.INFO)
end

-- Create a Neovim command to wrap text with blocks
vim.api.nvim_create_user_command('WrapGrok', function()
  wrap_with_blocks()
end, {})

-- vim.api.nvim_create_user_command(
--   'MC',
--   function(opts)
--     copy_with_qf_context(opts.args)
--   end,
--   { nargs = '+' } -- Takes one or more arguments
-- )

vim.api.nvim_create_user_command('MC', function(opts)
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
end, {
  nargs = '+',
  complete = function(_, _, _)
    return { 'copy', 'grok' }
  end,
})

-- Optional: Add a keybinding (uncomment and modify as needed)
-- vim.keymap.set('n', '<leader>cq', ':CopyWithQF ', { desc = 'Copy with Quickfix context' })
