vim.bo.makeprg = vim.fn.expand("./.venv/bin/python3") .. " %"
vim.bo.errorformat = [[%E\ \ File\ "%f"\,\ line\ %l%.%#,%-G%.%#]]
vim.keymap.set("n", "<leader>r", ":make<CR>", { buffer = true, desc = "Run Python script and capture errors" })
