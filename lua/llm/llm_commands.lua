local ding = require 'llm.llm'

local system_prompt =
  'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks'
local helpful_prompt = 'You are a helpful assistant. What I have sent are my notes so far.'
local math_prompt =
  'You are a helpful assistant and an applied mathematician specializing in the math of data science, compressed sensing an high-dimensional probability. You know how to write papers in a meaningful, ethical and impactful way.'
-- local function handle_open_router_spec_data(data_stream)
--   local success, json = pcall(vim.json.decode, data_stream)
--   if success then
--     if json.choices and json.choices[1] and json.choices[1].text then
--       local content = json.choices[1].text
--       if content then
--         ding.write_string_at_cursor(content)
--       end
--     end
--   else
--     print('non json ' .. data_stream)
--   end
-- end

-- local function custom_make_openai_spec_curl_args(opts, prompt)
--   local url = opts.url
--   local api_key = opts.api_key_name and os.getenv(opts.api_key_name)
--   local data = {
--     prompt = prompt,
--     model = opts.model,
--     temperature = 0.7,
--     stream = true,
--   }
--   local args = { '-N', '-X', 'POST', '-H', 'Content-Type: application/json', '-d', vim.json.encode(data) }
--   if api_key then
--     table.insert(args, '-H')
--     table.insert(args, 'Authorization: Bearer ' .. api_key)
--   end
--   table.insert(args, url)
--   return args
-- end

-- local function llama_405b_base()
--   ding.invoke_llm_and_stream_into_editor({
--     url = 'https://openrouter.ai/api/v1/chat/completions',
--     model = 'meta-llama/llama-3.1-405b',
--     api_key_name = 'OPEN_ROUTER_API_KEY',
--     max_tokens = '128',
--     replace = false,
--   }, custom_make_openai_spec_curl_args, handle_open_router_spec_data)
-- end

-- local function groq_replace()
--   ding.invoke_llm_and_stream_into_editor({
--     url = 'https://api.groq.com/openai/v1/chat/completions',
--     model = 'llama-3.1-70b-versatile',
--     api_key_name = 'GROQ_API_KEY',
--     system_prompt = system_prompt,
--     replace = true,
--   }, ding.make_openai_spec_curl_args, ding.handle_openai_spec_data)
-- end

-- local function groq_help()
--   ding.invoke_llm_and_stream_into_editor({
--     url = 'https://api.groq.com/openai/v1/chat/completions',
--     model = 'llama-3.1-70b-versatile',
--     api_key_name = 'GROQ_API_KEY',
--     system_prompt = helpful_prompt,
--     replace = false,
--   }, ding.make_openai_spec_curl_args, ding.handle_openai_spec_data)
-- end

-- local function llama405b_replace()
--   ding.invoke_llm_and_stream_into_editor({
--     url = 'https://api.lambdalabs.com/v1/chat/completions',
--     model = 'hermes-3-llama-3.1-405b-fp8',
--     api_key_name = 'LAMBDA_API_KEY',
--     system_prompt = system_prompt,
--     replace = true,
--   }, ding.make_openai_spec_curl_args, ding.handle_openai_spec_data)
-- end

-- local function llama405b_help()
--   ding.invoke_llm_and_stream_into_editor({
--     url = 'https://api.lambdalabs.com/v1/chat/completions',
--     model = 'hermes-3-llama-3.1-405b-fp8',
--     api_key_name = 'LAMBDA_API_KEY',
--     system_prompt = helpful_prompt,
--     replace = false,
--   }, ding.make_openai_spec_curl_args, ding.handle_openai_spec_data)
-- end

local function anthropic_help()
  ding.invoke_llm_and_stream_into_editor({
    url = 'https://api.anthropic.com/v1/messages',
    model = 'claude-3-5-sonnet-20241022',
    api_key_name = 'ANTHROPIC_API_KEY',
    system_prompt = helpful_prompt,
    replace = false,
  }, ding.basic_wrap_prompt, ding.make_anthropic_spec_curl_args_raw, ding.handle_anthropic_spec_data)
end

local function anthropic_replace()
  ding.invoke_llm_and_stream_into_editor({
    url = 'https://api.anthropic.com/v1/messages',
    model = 'claude-3-5-sonnet-20241022',
    api_key_name = 'ANTHROPIC_API_KEY',
    system_prompt = system_prompt,
    replace = true,
  }, ding.basic_wrap_prompt, ding.make_anthropic_spec_curl_args_raw, ding.handle_anthropic_spec_data)
end

local zettel_fns = require 'llm.llm_with_files'

local function anthropic_in_vault()
  ding.invoke_llm_and_stream_into_editor({
    url = 'https://api.anthropic.com/v1/messages',
    model = 'claude-3-5-sonnet-20241022',
    api_key_name = 'ANTHROPIC_API_KEY',
    system_prompt = math_prompt,
    replace = false,
    stream = true,
  }, zettel_fns.get_zettel_prompt_with_quickfix, ding.make_anthropic_spec_curl_args_raw, ding.handle_anthropic_spec_data)
end

-- Updated ShowLLMDiff function (renamed to show_llm_diff)
local function show_llm_diff(diff_string)
  local orig_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local tmp_current = vim.fn.tempname()
  local tmp_suggested = vim.fn.tempname()
  local tmp_diff = vim.fn.tempname()

  -- Write current buffer content to temp file
  vim.fn.writefile(orig_lines, tmp_current)

  -- Write diff to temp file
  vim.fn.writefile(vim.split(diff_string, '\n'), tmp_diff)

  -- Apply diff to create suggested version
  local patch_cmd = string.format('patch -o %s %s < %s', tmp_suggested, tmp_current, tmp_diff)
  local result = vim.fn.system(patch_cmd)
  if vim.v.shell_error ~= 0 then
    print('Error applying patch: ' .. result)
    return
  end

  local orig_buf = vim.api.nvim_get_current_buf()
  vim.cmd('vsplit ' .. tmp_suggested)
  vim.cmd 'wincmd p' -- Back to original
  vim.cmd 'diffthis'
  vim.cmd 'wincmd w' -- To suggested
  vim.cmd 'diffthis'

  -- Keymaps for applying/discard changes using native diff commands
  local opts = { noremap = true, silent = true, desc = 'Apply diff hunk' }
  vim.api.nvim_buf_set_keymap(orig_buf, 'n', '<leader>a', ':diffget<CR>', opts)
  vim.api.nvim_buf_set_keymap(orig_buf, 'n', '<leader>d', ':diffput<CR>', vim.tbl_extend('force', opts, { desc = 'Discard diff hunk' }))
end
-- New handler for non-streaming Anthropic response
local function handle_anthropic_spec(response)
  local diff_content = response.content[1].text
  vim.schedule(function()
    show_llm_diff(diff_content)
  end)
end

local function anthropic_diff()
  local diff_prompt = [[
Re-generate the FILE_TO_FIX with a small number of suggested improvements that are asked for in the prompt.  Your ouput is piped to a file, which will then be diffed with the original. Keep the new lines where they are, except if you have to change it because of changes to the text. As much as possible, keep the new lines where they are.
Only make a small number of useful changes.
DO NOT PUT CODE QUOTES like ``` OR like ', or ". Do not make any other commentary. The new file needs to match the old EXACTLY, except for your intended changes.
]]
  -- Get original buffer and content
  local orig_buf = vim.api.nvim_get_current_buf()
  local orig_lines = vim.api.nvim_buf_get_lines(orig_buf, 0, -1, false)
  -- get the entire content of the current buffer in a string. Be terse.
  local full_text = table.concat(orig_lines,"\n")

  local manual_prompt = vim.fn.input('Prompt: ')
  local prompt = "FILE_TO_FIX:'" .. full_text .. "'\n\n" .. "PROMPT:'" .. manual_prompt .. "'"

  -- Create new window and buffer
  local orig_win = vim.api.nvim_get_current_win()
  vim.api.nvim_command 'diffthis'
  vim.api.nvim_command 'vsplit'
  local suggested_win = vim.api.nvim_get_current_win()
  local suggested_buf = vim.api.nvim_create_buf(false, true) -- Scratch buffer
  vim.api.nvim_buf_set_option(suggested_buf, 'buftype', 'nofile')
  -- vim.api.nvim_buf_set_name(suggested_buf, 'LLM_Diff_Suggestions')
  vim.api.nvim_win_set_buf(suggested_win, suggested_buf)
  vim.api.nvim_command 'diffthis'

  -- Set keymaps
  local opts = { noremap = true, silent = true, desc = 'Apply diff hunk' }
  vim.api.nvim_buf_set_keymap(orig_buf, 'n', '<leader>a', ':diffget<CR>', opts)
  vim.api.nvim_buf_set_keymap(orig_buf, 'n', '<leader>d', ':diffput<CR>', vim.tbl_extend('force', opts, { desc = 'Discard diff hunk' }))

  print(prompt)
  -- Call LLM and process response
  ding.invoke_llm_and_stream_into_editor({
    url = 'https://api.anthropic.com/v1/messages',
    model = 'claude-3-5-sonnet-20241022',
    api_key_name = 'ANTHROPIC_API_KEY',
    system_prompt = diff_prompt,
    replace = false,
  }, function()
    return ding.basic_wrap_prompt(prompt)
  end, ding.make_anthropic_spec_curl_args_raw, ding.handle_anthropic_spec_data)
end

local function anthropic_diff()
  local diff_prompt = [[
Re-generate the FILE_TO_FIX with a small number of suggested improvements that are asked for in the prompt.  Your ouput is piped to a file, which will then be diffed with the original. Keep the new lines where they are, except if you have to change it because of changes to the text. As much as possible, keep the new lines where they are.
Only make a small number of useful changes.
DO NOT PUT CODE QUOTES like ``` OR like ', or ". Do not make any other commentary. The new file needs to match the old EXACTLY, except for your intended changes.
]]
  -- Get original buffer and content
  local orig_buf = vim.api.nvim_get_current_buf()
  local text = ''
  local visual_lines = ding.get_visual_selection()

  if visual_lines then
    text = table.concat(visual_lines,"\n")
    vim.api.nvim_command 'vsplit'
    local selection_win = vim.api.nvim_get_current_win()
    local selection_buf = vim.api.nvim_create_buf(false, true) -- Scratch buffer
    vim.api.nvim_buf_set_option(selection_buf, 'buftype', 'nofile')
    -- vim.api.nvim_buf_set_name(selection_buf, 'LLM_Diff_Suggestions')
    vim.api.nvim_win_set_buf(selection_win, selection_buf)
    vim.api.nvim_buf_set_text(0, 0, 0,-1, -1, visual_lines)
  else
    local orig_lines = vim.api.nvim_buf_get_lines(orig_buf, 0, -1, false)
    text = table.concat(orig_lines,"\n")
  end

  local manual_prompt = vim.fn.input('Prompt: ')
  local prompt = "FILE_TO_FIX:'" .. text .. "'\n\n" .. "PROMPT:'" .. manual_prompt .. "'"

  -- Create new window and buffer
  local orig_win = vim.api.nvim_get_current_win()
  vim.api.nvim_command 'diffthis'
  vim.api.nvim_command 'vsplit'
  local suggested_win = vim.api.nvim_get_current_win()
  local suggested_buf = vim.api.nvim_create_buf(false, true) -- Scratch buffer
  vim.api.nvim_buf_set_option(suggested_buf, 'buftype', 'nofile')
  -- vim.api.nvim_buf_set_name(suggested_buf, 'LLM_Diff_Suggestions')
  vim.api.nvim_win_set_buf(suggested_win, suggested_buf)
  vim.api.nvim_command 'diffthis'

  -- Set keymaps
  local opts = { noremap = true, silent = true, desc = 'Apply diff hunk' }
  vim.api.nvim_buf_set_keymap(orig_buf, 'n', '<leader>a', ':diffget<CR>', opts)
  vim.api.nvim_buf_set_keymap(orig_buf, 'n', '<leader>d', ':diffput<CR>', vim.tbl_extend('force', opts, { desc = 'Discard diff hunk' }))

  print(prompt)
  -- Call LLM and process response
  ding.invoke_llm_and_stream_into_editor({
    url = 'https://api.anthropic.com/v1/messages',
    model = 'claude-3-5-sonnet-20241022',
    api_key_name = 'ANTHROPIC_API_KEY',
    system_prompt = diff_prompt,
    replace = false,
  }, function()
    return ding.basic_wrap_prompt(prompt)
  end, ding.make_anthropic_spec_curl_args_raw, ding.handle_anthropic_spec_data)
end

-- ding.invoke_llm(
--   {
--     url = 'https://api.anthropic.com/v1/messages',
--     model = 'claude-3-5-sonnet-20241022',
--     api_key_name = 'ANTHROPIC_API_KEY',
--     system_prompt = diff_prompt,
--     replace = false,
--   },
--   ding.basic_wrap_prompt(prompt),
--   ding.make_anthropic_spec_curl_args_raw,
--   function(response)
--     vim.schedule(function()
--       print(vim.inspect(response))
--       -- Check for API error
--       if response.type == 'error' then
--         print('API Error: ' .. response.error.message)
--         return
--       end
--       local diff_content = response.content[1].text
--
--       -- Write original content and diff to temp files
--       local tmp_orig = vim.fn.tempname()
--       local tmp_diff = vim.fn.tempname()
--       vim.fn.writefile(orig_lines, tmp_orig)
--       vim.fn.writefile(vim.split(diff_content, '\n'), tmp_diff)
--
--       -- Apply patch
--       local tmp_suggested = vim.fn.tempname()
--       local patch_cmd = string.format('patch -o %s %s < %s', tmp_suggested, tmp_orig, tmp_diff)
--       local result = vim.fn.system(patch_cmd)
--       if vim.v.shell_error ~= 0 then
--         print('Error applying patch: ' .. result)
--         return
--       end
--
--       -- Update suggested buffer
--       local suggested_lines = vim.fn.readfile(tmp_suggested)
--       vim.api.nvim_buf_set_lines(suggested_buf, 0, -1, false, suggested_lines)
--
--       -- Clean up temp files
--       vim.fn.delete(tmp_orig)
--       vim.fn.delete(tmp_diff)
--       vim.fn.delete(tmp_suggested)
--     end)
--   end
--   )
-- end

-- Updated keymap for anthropic_diff
vim.keymap.set({ 'n', 'v' }, '<leader>cld', anthropic_diff, { desc = 'llm anthropic diff' })

-- vim.keymap.set({ 'n', 'v' }, '<leader>cl', groq_replace, { desc = 'llm groq' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>K', groq_help, { desc = 'llm groq_help' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>L', llama405b_help, { desc = 'llm llama405b_help' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>l', llama405b_replace, { desc = 'llm llama405b_replace' })
vim.keymap.set({ 'n', 'v' }, '<leader>clqh', anthropic_in_vault, { desc = 'llm quickfix help' })
vim.keymap.set({ 'n', 'v' }, '<leader>clh', anthropic_help, { desc = 'llm anthropic_help' })
vim.keymap.set({ 'n', 'v' }, '<leader>clr', anthropic_replace, { desc = 'llm anthropic' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>o', llama_405b_base, { desc = 'llama base' })
