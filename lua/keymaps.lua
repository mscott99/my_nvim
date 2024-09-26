-- Keymaps for better default experience
--
--
-- See `:help vim.keymap.set()`

local all_wrapped = nil

local function toggle_wrap_mode()
  local windows = vim.api.nvim_list_wins()
  local wrap_state = all_wrapped == nil or not all_wrapped

  for _, win_id in ipairs(windows) do
    vim.api.nvim_win_set_option(win_id, 'wrap', wrap_state)
  end

  all_wrapped = wrap_state
  vim.notify('Wrap mode set to ' .. (wrap_state and 'on' or 'off') .. ' for all windows.', vim.log.levels.INFO)
end

vim.keymap.set('n', '<leader>tw', toggle_wrap_mode, { desc = '[T]oggle [W]rap' })

vim.keymap.set('n', '<leader>dt', function()
  -- Get all windows
  local windows = vim.api.nvim_list_wins()
  -- Check if we have exactly two windows
  if #windows ~= 2 then
    vim.notify('Please ensure you have exactly two windows open.', vim.log.levels.WARN)
    return
  end

  -- Function to run diffthis on the current window
  local function run_diffthis()
    vim.cmd 'diffthis'
  end

  -- Function to set diffput and diffget keymaps for the current buffer
  local function set_diff_keymaps()
    vim.keymap.set('n', '<leader>dp', '<cmd>diffput<CR>', { buffer = true, desc = '[D]iff [P]ut' })
    vim.keymap.set('n', '<leader>dg', '<cmd>diffget<CR>', { buffer = true, desc = '[D]iff [G]et' })
  end

  -- Switch to the first window and set up
  vim.api.nvim_set_current_win(windows[1])
  run_diffthis()
  set_diff_keymaps()

  -- Switch to the second window and set up
  vim.api.nvim_set_current_win(windows[2])
  run_diffthis()
  set_diff_keymaps()

  -- Optionally, focus back on the first window
  vim.api.nvim_set_current_win(windows[1])
end, { desc = '[D]iff [T]his' })

vim.keymap.set('n', '<leader>ghd', '<cmd>:Gdiffsplit :1 | Gvdiffsplit!<cr>', { desc = 'Diff merge conflict' })
vim.keymap.set('n', '<leader>ghgb', '<cmd>diffget //1<cr>', { desc = 'Diff get base' })
vim.keymap.set('n', '<leader>ghgt', '<cmd>diffget //2<cr>', { desc = 'Diff get target branch' })
vim.keymap.set('n', '<leader>ghgm', '<cmd>diffget //3<cr>', { desc = 'Diff get merge branch' })

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', '<leader>tt', '<cmd>Toc<cr>', { desc = '[T]able [O]f [C]ontents' })

vim.keymap.set('n', '<leader>bd', '<cmd>bp | bd #<cr>', { desc = '[B]uffer [D]elete' })

--Search and replace from selection
vim.keymap.set('v', '<C-r>', [["hy:s/\V\(<C-R>=escape(@h, '/\')<cr>\)//g<left><left>]])

--Show file name
vim.keymap.set('n', '<leader>fn', '<cmd>echo expand("%:t")<cr>', { desc = '[F]ile [N]ame' })

--Copy file name without file extension
vim.keymap.set('n', '<leader>ga', '<cmd>let @+ = expand("%:t:r")<cr>', { desc = '[G]et file [A]ddress' })

--Next item in quickfix
vim.keymap.set({ 'n', 'i' }, '<C-n>', '<cmd>cnext<cr>', { desc = '[Q]uickfix [N]ext' })
-- Previous item in quickfix
vim.keymap.set({ 'n', 'i' }, '<C-p>', '<cmd>cprev<cr>', { desc = '[Q]uickfix [P]revious' })
-- Show quickfix
vim.keymap.set('n', '<leader>qo', '<cmd>copen<cr>', { desc = '[Q]uickfix [O]pen' })
-- Close quickfix
vim.keymap.set('n', '<leader>qn', '<cmd>cclose<cr>', { desc = '[Q]uickfix [N]ot' })

vim.keymap.set('n', '<leader>yr', '<cmd>!yabai --restart-service<cr>', { desc = '[Y]abai [R]estart' })

-- deal with sentences, even with surround plugins
vim.keymap.set('o', 'gas', 'as', { desc = '[A]round [S]entence' })
vim.keymap.set('o', 'gis', 'is', { desc = '[A]round [S]entence' })
-- Remap for dealing with word wrap
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>em', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
vim.keymap.set('n', '<leader>ep', '<cmd>Oil<CR>', { desc = '[E]x[P]lore' })

vim.keymap.set('n', '<leader>cf', '<cmd>Format<CR>', { desc = '[C]ode [F]ormat' })

vim.keymap.set('n', '<leader>qs', [[<cmd>lua require("persistence").load()<cr>]], {})

vim.keymap.set(
  'n',
  '<leader>cc',
  [[<cmd>edit oil-ssh://cc///home/mscott99/projects/def-oyilmaz/mscott99
<CR>]],
  { desc = '[C]ompute [C]an' }
)

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Go to below window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Go to above window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })

vim.keymap.set('n', '<leader>qq', [[<cmd>qa<cr>]])

vim.keymap.set({ 'n', 'i' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })

vim.keymap.set({ 'n', 'i' }, '<Esc>', '<Esc><cmd>noh<cr>')

-- Set up an autocommand for a specific filetype
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown', -- Replace with the filetype you want, e.g., "python", "markdown", etc.
  callback = function()
    -- Define your keymap here
    vim.keymap.set({ 'n', 'i' }, '<Esc>', '<Esc><cmd>noh | w<cr>', { buffer = true })
  end,
})

-- funky keymaps

vim.keymap.set('n', '<leader>fd', "<cmd>call delete(expand('%')) | bdelete!<CR>", { desc = '[F]ile [D]elete' })

vim.api.nvim_create_user_command('FileDelete', function()
  vim.cmd "call delete(expand('%')) | bdelete!"
end, {})

-- Open buffer in another split
local function open_buffer_in_split()
  local current_file = vim.fn.expand '%:p'
  local cursor = vim.api.nvim_win_get_cursor(0)
  -- Switch to the other split
  vim.cmd 'wincmd w'
  -- Open the current file in the other split
  vim.cmd('edit ' .. current_file)
  vim.api.nvim_win_set_cursor(0, cursor)
  vim.cmd 'ObsidianFollowLink'
end

vim.keymap.set('n', '<leader>gf', open_buffer_in_split, { desc = 'Go to file in other split' })

local concealed_cursor = true
vim.keymap.set('n', '<leader>th', function()
  if concealed_cursor then
    concealed_cursor = false
    vim.cmd 'set concealcursor=nvic'
    vim.notify('Conceal cursor enabled', vim.log.levels.INFO)
  else
    concealed_cursor = true
    vim.cmd 'set concealcursor='
    vim.notify('Conceal cursor disabled', vim.log.levels.INFO)
  end
end, { desc = '[T]oggle [H]ide (conceal)' })

local function load_wikilinks_to_quickfix()
  -- Pattern for matching wikilinks
  local pattern = '%[%[.-%]%]'
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local locations = {}
  for lnum, line in ipairs(lines) do
    for match in line:gmatch(pattern) do
      local col = line:find(match, 1, true)
      table.insert(locations, {
        bufnr = bufnr,
        lnum = lnum,
        col = col,
        text = line
      })
    end
  end
  vim.fn.setqflist(locations, 'r')
  vim.cmd('cfirst')
  -- vim.cmd('lopen')
end
vim.keymap.set('n', '<leader>gw', load_wikilinks_to_quickfix, { desc = '[L]oad [W]ikilinks' })

-- Some primagen shortcuts
vim.keymap.set({ 'n', 'x', 'v' }, '<Cmd-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>', { desc = 'Go to another tmux place.' })
vim.keymap.set('x', '<leader>p', [["_dP]])
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>Y', [["+Y]])
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]])

vim.api.nvim_set_keymap('x', 'J', 'J', { noremap = true, silent = true })
vim.keymap.set('v', 'J', 'mzJ`z')
-- vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set('x', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set({ 'x', 'n' }, 'H', '^') -- Make H for alternate file

vim.keymap.set('n', '<leader>cp', [[<cmd>let @+ = expand("%:p")<CR>]], { desc = '[C]opy [P]ath' })
