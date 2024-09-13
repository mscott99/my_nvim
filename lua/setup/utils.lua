-- Register function as a neovim command using lua syntax
-- vim.api.nvim_create_user_command("LatexToObsidian", function()
--     vim.cmd([=[%s/\\emph{\(.\{-}\)}/\*\1\*/g]=])
--     vim.cmd([[%s/``\(.\{-}\)''/"\1"/g]])
--     vim.cmd([[%s/\\cite{\(.\{-}\)}/[[@\1]]/g]])
--     vim.cmd([[%s/\\paragraph{\(.\{-}\)}/## \1/]])
--     vim.cmd([[%s/\\cite\[\(.\{-}\)\]{\(.\{-}\)}/[[@\2]][\1]/g]])
-- end, {})

vim.api.nvim_create_user_command("ToAlign", function()
  vim.cmd[[norm! 0ea$hikVgsagsaealign*wi&A\\]]
end, {})
