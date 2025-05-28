vim.bo.makeprg = "julia --project %"

-- Set errorformat to capture path:line and ignore all other lines
-- vim.bo.errorformat = [[ [%n] %.%#,   @%.%# %f:%l]]
vim.bo.errorformat = [[%E [%n]%m,%Z   @%.%# %f:%l,%-G%.%#]]
