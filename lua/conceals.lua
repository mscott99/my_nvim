-- Define a function to setup custom conceals
local function setup_custom_conceals()
  -- Use vim.api.nvim_exec to run Vimscript for syntax matching
  vim.cmd [[
    syntax match texMathCmd '\\indep' conceal cchar=⊨
    syntax match texMathCmd '\\range' conceal cchar=ℛ
    syntax match texMathCmd '\\rank' conceal cchar=r
    syntax match texMathCmd '\\diag' conceal cchar=d
    syntax match texMathCmd '\\prod' conceal cchar=Π
    syntax match texMathCmd '\\prob' conceal cchar=P
    syntax match texMathCmd '\\proj' conceal cchar=Π
    syntax match texMathCmd '\\hull' conceal cchar=h
    " syntax match texMathCmd '\\\<argsup' conceal cchar=\0
    " syntax match texMathCmd '\\\<arginf' conceal cchar=\0
    syntax match texMathCmd '\\lesssim' conceal cchar=≲
    syntax match texMathCmd '\\gtrsim' conceal cchar=≳
    syntax match texMathCmd '\\colonequals' conceal cchar=≔

    syntax match texMathCmd '\\boldsymbol{e}' conceal cchar=𝐞
    syntax match texMathCmd '\\bar{\\cap}' conceal cchar=⩃
    syntax match texMathCmd '\\indicator' conceal cchar=𝟙
    ]]
  -- Additional syntax matches can be added here
end

vim.cmd [[
    let g:mkdp_preview_options = {
        \ 'mkit': {},
        \ 'katex': {'macros': {"\\proj": "\\Pi", "\\bR": "\\mathbb{R}", "\\ker": "\\mathrm{ker}", "\\indicator":"\\mathbb{1}", "\\minimize": "\\mathbb{minimize}", "\\maximize": "\\mathbb{maximize}", "\\argmin": "\\mathbb{argmin}", "\\argmax": "\\mathbb{argmax}", "\\range": "\\mathbb{range}", "\\prob": "\\mathbb{P}", "\\hull": "\\mathbb{H}", "\\span": "\\mathbb{span}", "\\aff": "\\mathbb{aff}", "\\indep": "\perp\!\!\!\!\perp", "\\rank": "\\mathbb{rank}", "\\diag": "\\mathbb{diag}"},},
        \ 'uml': {},
        \ 'maid': {},
        \ 'disable_sync_scroll': 0,
        \ 'sync_scroll_type': 'middle',
        \ 'hide_yaml_meta': 1,
        \ 'sequence_diagrams': {},
        \ 'flowchart_diagrams': {},
        \ 'content_editable': v:false,
        \ 'disable_filename': 0,
        \ 'toc': {}
        \ }
    ]]

-- Create an autocommand group for markdown conceal settings
local markdown_conceal_group = vim.api.nvim_create_augroup('MarkdownConceal', { clear = true })

-- Register autocommands to run the setup function on specific events and filetypes
vim.api.nvim_create_autocmd({ 'VimEnter', 'BufWinEnter' }, {
  group = markdown_conceal_group,
  pattern = '*.md',
  callback = setup_custom_conceals,
})
