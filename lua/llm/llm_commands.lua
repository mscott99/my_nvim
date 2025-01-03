local ding=require("llm.llm")

local system_prompt =
  'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks'
local helpful_prompt = 'You are a helpful assistant. What I have sent are my notes so far.'
local math_prompt = 'You are a helpful assistant and an applied mathematician specializing in the math of data science, compressed sensing an high-dimensional probability. You know how to write papers in a meaningful, ethical and impactful way.'
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

zettel_fns = require "llm.llm_with_files"

local function anthropic_in_vault()
  ding.invoke_llm_and_stream_into_editor({
    url = 'https://api.anthropic.com/v1/messages',
    model = 'claude-3-5-sonnet-20241022',
    api_key_name = 'ANTHROPIC_API_KEY',
    system_prompt = math_prompt,
    replace = false,
  }, zettel_fns.get_zettel_prompt_with_quickfix , ding.make_anthropic_spec_curl_args_raw, ding.handle_anthropic_spec_data)
end

-- vim.keymap.set({ 'n', 'v' }, '<leader>cl', groq_replace, { desc = 'llm groq' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>K', groq_help, { desc = 'llm groq_help' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>L', llama405b_help, { desc = 'llm llama405b_help' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>l', llama405b_replace, { desc = 'llm llama405b_replace' })
vim.keymap.set({ 'n', 'v' }, '<leader>clqh', anthropic_in_vault, { desc = 'llm quickfix help' })
vim.keymap.set({ 'n', 'v' }, '<leader>clh', anthropic_help, { desc = 'llm anthropic_help' })
vim.keymap.set({ 'n', 'v' }, '<leader>clr', anthropic_replace, { desc = 'llm anthropic' })
-- vim.keymap.set({ 'n', 'v' }, '<leader>o', llama_405b_base, { desc = 'llama base' })
