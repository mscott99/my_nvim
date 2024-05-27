-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', '<leader>tt', '<cmd>Toc<cr>', {desc= "[T]able [O]f [C]ontents"})

--Search and replace from selection
vim.keymap.set('v', "<C-r>", [["hy:s/\V\(<C-R>=@h<cr>\)//g<left><left>]])

--Show file name
vim.keymap.set('n', '<leader>fn', '<cmd>echo expand("%:t")<cr>', {desc = "[F]ile [N]ame"})

--Copy file name without file extension
vim.keymap.set('n', '<leader>ga', '<cmd>let @+ = expand("%:t:r")<cr>', {desc = "[G]et file [A]ddress"})

--Next item in quickfix
vim.keymap.set({'n', 'i'}, '<C-n>', '<cmd>cnext<cr>', {desc = "[Q]uickfix [N]ext"})
-- Previous item in quickfix
vim.keymap.set({'n', 'i'}, '<C-p>', '<cmd>cprev<cr>', {desc = "[Q]uickfix [P]revious"})
-- Show quickfix
vim.keymap.set('n', '<leader>qo', '<cmd>copen<cr>', {desc = "[Q]uickfix [O]pen"})
-- Close quickfix
vim.keymap.set('n', '<leader>qn', '<cmd>cclose<cr>', {desc = "[Q]uickfix [N]ot"})


-- deal with sentences, even with surround plugins
vim.keymap.set('o', "gas", "as", {desc="[A]round [S]entence"})
vim.keymap.set('o', "gis", "is", {desc="[A]round [S]entence"})
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>em', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
vim.keymap.set('n', '<leader>ep', "<cmd>Oil<CR>", {desc = "[E]x[P]lore"})

vim.keymap.set('n', '<leader>cf', '<cmd>Format<CR>', { desc = '[C]ode [F]ormat' })

vim.keymap.set("n", "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]], {})

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

vim.keymap.set("n", "<leader>qq", [[<cmd>qa<cr>]])

vim.keymap.set({'n', 'i'}, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set('n', "<Esc>", "<Esc><cmd>noh<cr>")

-- funky keymaps

vim.keymap.set("n", "<leader>fd", "<cmd>call delete(expand('%')) | bdelete!<CR>", {desc = "[F]ile [D]elete"})

vim.api.nvim_create_user_command('FileDelete', function()
   vim.cmd("call delete(expand('%')) | bdelete!")
end, {})

-- Open buffer in another split
local function open_buffer_in_split()
   local current_file = vim.fn.expand('%:p')
   local cursor = vim.api.nvim_win_get_cursor(0)
   -- Switch to the other split
   vim.cmd('wincmd w')
   -- Open the current file in the other split
   vim.cmd('edit ' .. current_file)
   vim.api.nvim_win_set_cursor(0, cursor)
   vim.cmd('ObsidianFollowLink')
end

vim.keymap.set("n", "<leader>gf", open_buffer_in_split, {desc = "Go to file in other split"})

-- Some primagen shortcuts
vim.keymap.set({ "n", "x", "v" }, "<Cmd-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Go to another tmux place." })

vim.keymap.set({ "v" }, "J", "mzJ`z")
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set({ "x", "n" }, "H", "^") -- Make H for alternate file

vim.keymap.set("n", "<leader>cp", [[<cmd>let @+ = expand("%:p")<CR>]], { desc = "[C]opy [P]ath"})
