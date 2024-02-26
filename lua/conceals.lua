-- Define a function to setup custom conceals
local function setup_custom_conceals()
    -- Use vim.api.nvim_exec to run Vimscript for syntax matching
    vim.cmd [[
    syntax match texMathCmd '\\range' conceal cchar=ℛ
    syntax match texMathCmd '\\prod' conceal cchar=Π
    syntax match texMathCmd '\\prob' conceal cchar=P
    syntax match texMathCmd '\\proj' conceal cchar=Π
    " syntax match texMathCmd '\\\<argsup' conceal cchar=\0
    " syntax match texMathCmd '\\\<arginf' conceal cchar=\0
    syntax match texMathCmd '\\lesssim' conceal cchar=≲
    syntax match texMathCmd '\\gtrsim' conceal cchar=≳
    syntax match texMathCmd '\\colonequals' conceal cchar=≔
    ]]
    -- Additional syntax matches can be added here
end

-- Create an autocommand group for markdown conceal settings
local markdown_conceal_group = vim.api.nvim_create_augroup("MarkdownConceal", { clear = true })

-- Register autocommands to run the setup function on specific events and filetypes
vim.api.nvim_create_autocmd({"VimEnter", "BufWinEnter"}, {
    group = markdown_conceal_group,
    pattern = "*.md",
    callback = setup_custom_conceals,
})
