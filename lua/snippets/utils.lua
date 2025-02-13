local M = {}
local ts = require 'vim.treesitter'
local ls = require 'luasnip'
local sn = ls.snippet_node
local i = ls.insert_node

-- Get the index of the preceding latex block.
local match_latex = function(line, pos, break_pattern)
  local stack = {}
  -- local close = { ['}'] = true, ['%)'] = true, ['%]'] = true, ['\\}'] = true }
  -- local match = { ['}'] = '{', ['%)'] = '%(', ['%]'] = '%[', ['\\}'] = '\\{' }
  local close = {
    ['}'] = true,
    ['%)'] = true,
    ['%]'] = true,
    ['\\right%)'] = true,
    ['\\right%]'] = true,
    ['\\right\\}'] = true,
    ['\\right|'] = true,
    ['\\right\\|'] = true,
    ['\\right\\rangle'] = true,
    ['\\right\\rceil'] = true,
    ['\\right\\rfloor'] = true,
    ['\\right\\rrbracket'] = true,
    ['\\}'] = true,
    ['\\|'] = true,
    ['\\rangle'] = true,
    ['\\rceil'] = true,
    ['\\rfloor'] = true,
    ['\\rrbracket'] = true,
    ['\\rvert'] = true,
    ['\\rVert'] = true,
  }
  local match = {
    ['}'] = '{',
    ['%)'] = '%(',
    ['%]'] = '%[',
    ['\\right%)'] = '\\left%(',
    ['\\right%]'] = '\\left%[',
    ['\\right\\}'] = '\\left\\{',
    ['\\right|'] = '\\left|',
    ['\\right\\|'] = '\\left\\|',
    ['\\right\\rangle'] = '\\left\\langle',
    ['\\right\\rceil'] = '\\left\\lceil',
    ['\\right\\rfloor'] = '\\left\\lfloor',
    ['\\right\\rrbracket'] = '\\left\\llbracket',
    ['\\}'] = '\\{',
    ['\\|'] = '\\|',
    ['\\rangle'] = '\\langle',
    ['\\rceil'] = '\\lceil',
    ['\\rfloor'] = '\\lfloor',
    ['\\rrbracket'] = '\\llbracket',
    ['\\rvert'] = '\\lvert',
    ['\\rVert'] = '\\lVert',
  }
  local first_letter = true
  for i = pos, 1, -1 do
    local preceding_str = line:sub(1, i)
    if #stack >= 1 then
      local opening_match = match[stack[#stack]] .. '$'
      if preceding_str:match(opening_match) ~= nil then
        local removed = table.remove(stack)
        i = i - #removed + 1 -- will be decremented
        goto continue
      end
    end
    if #stack == 0 and not first_letter and (preceding_str == '' or preceding_str:match(break_pattern) ~= nil) then
      return i
    end
    for closing, _ in pairs(close) do
      if preceding_str:match(closing .. '$') then
        table.insert(stack, closing)
        i = i - #closing + 1 -- will be decremented
        goto continue
      end
    end
    if #stack ~= 0 and (preceding_str:sub(-1) == nil or preceding_str:sub(-1) == '' or preceding_str:sub(-1) == '$') then
      vim.notify('Invalid LaTeX syntax: unmatched brackets.', vim.log.levels.WARN)
      return pos
    end
    ::continue::
    first_letter = false
  end
  return pos
end

M.grab_latex_at_cursor = function(break_pattern)
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_buf_get_lines(0, pos[1] - 1, pos[1], false)[1]
  local match_start = match_latex(line, pos[2], break_pattern)
  local match_content = line:sub(match_start + 1, pos[2])
  if match_content ~= nil then
    vim.api.nvim_buf_set_text(0, pos[1] - 1, match_start, pos[1] - 1, pos[2], { '' })
  else
    vim.notify 'Could not get the latex content'
    return nil
  end
  -- Return the matched text
  return match_content
end

M.loose_grab = function()
  return M.grab_latex_at_cursor "[%s${%[%($]$"
end

M.strict_grab = function()
  return M.grab_latex_at_cursor "[%s${}%[%]%(%)%]_%-%+%|]$"
end

function M.get_visual(_, parent) -- use with dynamic node d(1, get_visual)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

-- Make function grab the code on the previous line
-- We do this to automate copy-pasting in align environments in latex
-- Do not include the first word starting with &, and do not include the last "\\" at the end of the line.
-- check that the previous line is not the start of the align environment

function M.get_prev_align_line(_, _)
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 2
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]

  -- Check if the line is the start of the align or align* environment
  if line:match '\\begin{align%*?}' then
    return sn(nil, i(1, ''))
  end

  local start, stop = 1, #line -- Initialize stop at the end of the line

  -- Update start if line starts with '&'
  local ampersand_pos = line:find '&'
  if ampersand_pos then
    -- Find the end of the first word/command after '&'
    local command_end = line:find('%s', ampersand_pos)
    if command_end then
      start = command_end + 1
    end
  end

  -- Update stop if line ends with '\\'
  local backslash_pos = line:find '\\\\%s*$'
  if backslash_pos then
    stop = backslash_pos - 1
  end

  local code = line:sub(start, stop)
  return sn(nil, i(1, code))
end

function M.map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
    t[k] = f(v)
  end
  return t
end

function M.concat(tables)
  local v = {}
  for _, value in pairs(tables) do
    vim.list_extend(v, value)
  end
  return v
end

function M.tableConcat(t1, t2)
  for j = 1, #t2 do
    t1[#t1 + 1] = t2[j]
  end
  return t1
end

function M.doubleMap(first, second, fn)
  local result = {}
  for _, f in ipairs(first) do
    for _, s in ipairs(second) do
      result[#result + 1] = fn(f, s)
      fn(f, s)
    end
  end
  return result
end

local function check_in_mathzone()
  local buf = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  col = col
  local parser = ts.get_parser(buf)
  parser:parse(true)
  if
    parser:children()['markdown_inline'] ~= nil
    and parser:children()['markdown_inline']:children()['latex'] ~= nil
    and parser:children()['markdown_inline']:children()['latex']:contains { row, col - 1, row, col }
  then
    return true
  else
    return false
  end
end

-- -- caching, but maybe not necessary
-- vim.api.nvim_create_autocmd({ "BufNew", "BufEnter", "BufWinEnter" }, {
--   pattern = { "*.md", "*.tex" },
--   callback = function()
--     if not vim.b.tracking_math then
--       vim.api.nvim_buf_attach(0, false, {
--         on_lines = function(...)
--           vim.b.in_mathzone = check_in_mathzone()
--         end,
--       })
--       vim.b.in_mathzone = false
--       vim.b.tracking_math = true
--     end
--   end,
-- })
--

M.greek_letters = {
  'alpha',
  'Alpha',
  'beta',
  'Beta',
  'delta',
  'Delta',
  'psi',
  'Psi',
  'xi',
  'Xi',
  'Epsilon',
  'gamma',
  'Gamma',
  'iota',
  'Iota',
  'kappa',
  'Kappa',
  'lambda',
  'Lambda',
  'mu',
  'Mu',
  'nu',
  'Nu',
  'omega',
  'Omega',
  'phi',
  'Phi',
  'pi',
  'Pi',
  'rho',
  'Rho',
  'sigma',
  'Sigma',
  'theta',
  'Theta',
  'tau',
  'Tau',
  'zeta',
  'Zeta',
  'Eta',
  'nabla',
  'Nabla',
  'chi',
  'Chi',
}

M.short_greek = {
  'nu',
  'Nu',
  'pi',
  'Pi',
  'mu',
  'Mu',
  'eta',
  'Eta',
}

local others = {
  'varepsilon',
  'varphi'
}

M.redundant_starting_greeks = M.concat { M.greek_letters, others, M.short_greek }

function M.in_markdown_mathzone()
  return check_in_mathzone()
  -- return vim.b.in_mathzone
end

function M.not_in_markdown_mathzone()
  return not check_in_mathzone()
  -- return not vim.b.in_mathzone
end

function M.in_tex_mathzone()
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

function M.not_in_tex_mathzone()
  return not vim.fn['vimtex#syntax#in_mathzone']() == 1
end

return M
