-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>em', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
vim.keymap.set('n', '<leader>ep', "<cmd>Explore<CR>", {desc = "[E]x[P]lore"})

vim.keymap.set('n', '<leader>cf', '<cmd>Format<CR>', { desc = '[C]ode [F]ormat' })

vim.keymap.set("n", "<leader>qs", [[<cmd>lua require("persistence").load()<cr>]], {})

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to below window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to above window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

vim.keymap.set("n", "<leader>qq", [[<cmd>qa<cr>]])

vim.keymap.set({'n', 'i'}, "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set('n', "<Esc>", "<cmd>noh<cr><Esc>")

-- funky keymaps

vim.keymap.set("n", "<leader>fd", "<cmd>call delete(expand('%')) | bdelete!<CR>", {desc = "[F]ile [D]elete"})

vim.api.nvim_create_user_command('FileDelete', function()
   vim.cmd("call delete(expand('%')) | bdelete!")
end, {})

-- Some primagen shortcuts
vim.keymap.set({ "n", "x", "v" }, "<Cmd-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Go to another tmux place." })

vim.keymap.set({ "v" }, "J", "mzJ`z")
vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set({ "x", "n" }, "H", "^") -- Make H for alternate file

vim.keymap.set("n", "<leader>cn", [[<cmd>let @+ = expand("%")<CR>]], { desc = "[C]opy file [N]ame"})
vim.keymap.set("n", "<leader>cp", [[<cmd>let @+ = expand("%:p")<CR>]], { desc = "[C]opy [P]ath"})
