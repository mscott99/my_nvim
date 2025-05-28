local M = {}

-- Helper function to strip leading/trailing whitespace and ensure trailing newline
local function normalize_text(text)
  text = text:gsub('^%s+', ''):gsub('%s+$', '')
  if text ~= '' and not text:match '\n$' then
    text = text .. '\n'
  end
  return text
end

-- Parse SEARCH/REPLACE blocks from LLM output
-- Returns a table of { filepath, search_text, replace_text } tables
function M.parse_search_replace_blocks(content)
  local blocks = {}
  local lines = vim.split(content, '\n', { plain = true })
  local i = 1
  local current_filepath = nil

  while i <= #lines do
    local line = lines[i]

    -- Look for a potential filepath (not starting with fence or markers)
    if line:match '^[^`<%s]' and not line:match '^<<<<<<< SEARCH$' and not line:match '^```' then
      current_filepath = line:match '^%s*(.+)%s*$'
    end

    -- Look for start of a SEARCH/REPLACE block
    if line:match '^<<<<<<< SEARCH$' then
      local search_lines = {}
      i = i + 1

      -- Collect SEARCH lines until divider
      while i <= #lines and not lines[i]:match '^=======$' do
        table.insert(search_lines, lines[i])
        i = i + 1
      end

      if i > #lines or not lines[i]:match '^=======$' then
        vim.notify('Invalid SEARCH/REPLACE block: missing divider', vim.log.levels.ERROR)
        return blocks
      end

      i = i + 1 -- Skip divider
      local replace_lines = {}

      -- Collect REPLACE lines until end marker
      while i <= #lines and not lines[i]:match '^>>>>>>> REPLACE$' do
        table.insert(replace_lines, lines[i])
        i = i + 1
      end

      if i > #lines or not lines[i]:match '^>>>>>>> REPLACE$' then
        vim.notify('Invalid SEARCH/REPLACE block: missing REPLACE end', vim.log.levels.ERROR)
        return blocks
      end

      if current_filepath then
        table.insert(blocks, {
          filepath = current_filepath,
          search_text = normalize_text(table.concat(search_lines, '\n')),
          replace_text = normalize_text(table.concat(replace_lines, '\n')),
        })
      else
        vim.notify('Missing filepath for SEARCH/REPLACE block', vim.log.levels.ERROR)
      end
    end

    i = i + 1
  end

  return blocks
end

-- Apply a single SEARCH/REPLACE block to a file
function M.apply_search_replace_block(block)
  local filepath = vim.fn.expand(block.filepath) -- Resolve ~, %, etc.
  if not vim.fn.filereadable(filepath) then
    if vim.fn.confirm('Create new file ' .. filepath .. '?', '&Yes\n&No') == 1 then
      vim.fn.writefile('', filepath)
    else
      vim.notify('Skipping non-existent file: ' .. filepath, vim.log.levels.WARN)
      return false
    end
  end

  local lines = vim.fn.readfile(filepath)
  local content = table.concat(lines, '\n') .. '\n'
  local search_text = block.search_text
  local replace_text = block.replace_text

  -- Check for exact match
  if not content:find(search_text, 1, true) then
    vim.notify('SEARCH block not found in ' .. filepath, vim.log.levels.ERROR)
    return false
  end

  -- Perform the replacement
  local new_content = content:gsub(search_text:gsub('%.', '%%.'), replace_text, 1)
  vim.fn.writefile(vim.split(new_content, '\n', { trimempty = true }), filepath)
  vim.notify('Applied SEARCH/REPLACE to ' .. filepath, vim.log.levels.INFO)
  return true
end

-- Apply all SEARCH/REPLACE blocks parsed from content
function M.apply_all_search_replace_blocks(content)
  local blocks = M.parse_search_replace_blocks(content)
  local success_count = 0
  local fail_count = 0

  for _, block in ipairs(blocks) do
    if M.apply_search_replace_block(block) then
      success_count = success_count + 1
    else
      fail_count = fail_count + 1
    end
  end

  if success_count > 0 then
    vim.notify(string.format('Applied %d SEARCH/REPLACE blocks', success_count), vim.log.levels.INFO)
  end
  if fail_count > 0 then
    vim.notify(string.format('Failed to apply %d SEARCH/REPLACE blocks', fail_count), vim.log.levels.ERROR)
  end
end

-- Builds a prompt for an LLM to generate a plan followed by SEARCH/REPLACE blocks
function M.build_editblock_prompt(user_input)
  -- Base system prompt, inspired by aider's EditBlockPrompts.main_system
  local search_replace_setup = [[
Take the user's request and respond with:
1. A concise general plan (in plain text, 2-5 sentences) outlining the approach to implement the requested changes.
2. A series of *SEARCH/REPLACE* blocks to apply the changes, following the exact format specified below.

If the request is ambiguous, clarify by explaining the ambiguity in the plan and propose a reasonable interpretation. If changes are needed in files not provided in the context, list their full paths in the plan and explain why they are needed, but do not generate *SEARCH/REPLACE* blocks for them.

All code changes must be provided in *SEARCH/REPLACE* blocks. Do not include code outside these blocks unless explicitly requested.
]]

  -- Platform information, inspired by aider's get_platform_info
  --   local platform_info = [[
  --
  -- Platform: mac
  -- Language: ]] .. (vim.env.LANG or vim.env.LC_ALL or 'unknown') .. [[
  -- Current date: ]] .. os.date '%Y-%m-%d' .. [[
  --
  -- The user is operating in a Neovim environment with git for version control.
  -- ]]
  -- *SEARCH/REPLACE* block rules, adapted from aider's system_reminder
  local search_replace_rules = [[
example_messages = [
        dict(
            role="user",
            content="Change get_factorial() to use math.factorial",
        ),
        dict(
            role="assistant",
            content="""To make this change we need to modify `mathweb/flask/app.py` to:

1. Import the math package.
2. Remove the existing factorial() function.
3. Update get_factorial() to call math.factorial instead.

Here are the *SEARCH/REPLACE* blocks:

mathweb/flask/app.py
<<<<<<< SEARCH
from flask import Flask
=======
import math
from flask import Flask
>>>>>>> REPLACE

mathweb/flask/app.py
<<<<<<< SEARCH
def factorial(n):
    "compute factorial"

    if n == 0:
        return 1
    else:
        return n * factorial(n-1)

=======
>>>>>>> REPLACE

mathweb/flask/app.py
{fence[0]}python
<<<<<<< SEARCH
    return str(factorial(n))
=======
    return str(math.factorial(n))
>>>>>>> REPLACE
""",
        ),
        dict(
            role="user",
            content="Refactor hello() into its own file.",
        ),
        dict(
            role="assistant",
            content="""To make this change we need to modify `main.py` and make a new file `hello.py`:

1. Make a new hello.py file with hello() in it.
2. Remove hello() from main.py and replace it with an import.

Here are the *SEARCH/REPLACE* blocks:

hello.py
<<<<<<< SEARCH
=======
def hello():
    "print a greeting"

    print("hello")
>>>>>>> REPLACE

main.py
<<<<<<< SEARCH
def hello():
    "print a greeting"

    print("hello")
=======
from hello import hello
>>>>>>> REPLACE
""",
        ),
        ]
# *SEARCH/REPLACE block* Rules:

Every *SEARCH/REPLACE block* must use this format:
1. The *FULL* file path alone on a line, verbatim. No bold asterisks, no quotes around it, no escaping of characters, etc.
2. The start of search block: <<<<<<< SEARCH
3. A contiguous chunk of lines to search for in the existing source code
4. The dividing line: =======
5. The lines to replace into the source code
6. The end of the replace block: >>>>>>> REPLACE

Use the *FULL* file path, as shown to you by the user.
{quad_backtick_reminder}
Every *SEARCH* section must *EXACTLY MATCH* the existing file content, character for character, including all comments, docstrings, etc.
If the file contains code or other data wrapped/escaped in json/xml/quotes or other containers, you need to propose edits to the literal contents of the file, including the container markup.

*SEARCH/REPLACE* blocks will *only* replace the first match occurrence.
Including multiple unique *SEARCH/REPLACE* blocks if needed.
Include enough lines in each SEARCH section to uniquely match each set of lines that need to change.

Keep *SEARCH/REPLACE* blocks concise.
Break large *SEARCH/REPLACE* blocks into a series of smaller blocks that each change a small portion of the file.
Include just the changing lines, and a few surrounding lines if needed for uniqueness.
Do not include long runs of unchanging lines in *SEARCH/REPLACE* blocks.

Only create *SEARCH/REPLACE* blocks for files that the user has added to the chat!

To move code within a file, use 2 *SEARCH/REPLACE* blocks: 1 to delete it from its current location, 1 to insert it in the new location.

Pay attention to which filenames the user wants you to edit, especially if they are asking you to create a new file.

If you want to put code in a new file, use a *SEARCH/REPLACE block* with:
- A new file path, including dir name if needed
- An empty `SEARCH` section
- The new file's contents in the `REPLACE` section

You are diligent and tireless!
You NEVER leave comments describing code without implementing it!
You always COMPLETELY IMPLEMENT the needed code!

ONLY EVER RETURN CODE IN A *SEARCH/REPLACE BLOCK*!
]]
  return search_replace_setup .. search_replace_rules
end

-- Command to apply SEARCH/REPLACE blocks from the current buffer
vim.api.nvim_create_user_command('ApplySearchReplace', function()
  local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
  M.apply_all_search_replace_blocks(content)
end, {})

return M
