-- Conceals have significant overhead --
-- Define a function to setup custom conceals
local function setup_custom_conceals()
  -- Use vim.api.nvim_exec to run Vimscript for syntax matching
  vim.cmd [[
    syntax match texMathCmd '\\indep' conceal cchar=⊨
    syntax match texMathCmd '\\range' conceal cchar=ℛ
    syntax match texMathCmd '\\interior' conceal cchar=i
    syntax match texMathCmd '\\rank' conceal cchar=r
    syntax match texMathCmd '\\diag' conceal cchar=d
    syntax match texMathCmd '\\Diag' conceal cchar=D
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
    syntax match texMathCmd '\\allone' conceal cchar=𝟙

    syntax match texMathCmd '\\boldsymbol{a}' conceal cchar=𝒂
    syntax match texMathCmd '\\boldsymbol{b}' conceal cchar=𝒃
    syntax match texMathCmd '\\boldsymbol{c}' conceal cchar=𝒄
    syntax match texMathCmd '\\boldsymbol{d}' conceal cchar=𝒅
    syntax match texMathCmd '\\boldsymbol{e}' conceal cchar=𝒆
    syntax match texMathCmd '\\boldsymbol{f}' conceal cchar=𝒇
    syntax match texMathCmd '\\boldsymbol{g}' conceal cchar=𝒈
    syntax match texMathCmd '\\boldsymbol{h}' conceal cchar=𝒉
    syntax match texMathCmd '\\boldsymbol{i}' conceal cchar=𝒊
    syntax match texMathCmd '\\boldsymbol{j}' conceal cchar=𝒋
    syntax match texMathCmd '\\boldsymbol{k}' conceal cchar=𝒌
    syntax match texMathCmd '\\boldsymbol{l}' conceal cchar=𝒍
    syntax match texMathCmd '\\boldsymbol{m}' conceal cchar=𝒎
    syntax match texMathCmd '\\boldsymbol{n}' conceal cchar=𝒏
    syntax match texMathCmd '\\boldsymbol{o}' conceal cchar=𝒐
    syntax match texMathCmd '\\boldsymbol{p}' conceal cchar=𝒑
    syntax match texMathCmd '\\boldsymbol{q}' conceal cchar=𝒒
    syntax match texMathCmd '\\boldsymbol{r}' conceal cchar=𝒓
    syntax match texMathCmd '\\boldsymbol{s}' conceal cchar=𝒔
    syntax match texMathCmd '\\boldsymbol{t}' conceal cchar=𝒕
    syntax match texMathCmd '\\boldsymbol{u}' conceal cchar=𝒖
    syntax match texMathCmd '\\boldsymbol{v}' conceal cchar=𝒗
    syntax match texMathCmd '\\boldsymbol{w}' conceal cchar=𝒘
    syntax match texMathCmd '\\boldsymbol{x}' conceal cchar=𝒙
    syntax match texMathCmd '\\boldsymbol{y}' conceal cchar=𝒚
    syntax match texMathCmd '\\boldsymbol{z}' conceal cchar=𝒛
    syntax match texMathCmd '\\boldsymbol{A}' conceal cchar=𝑨
    syntax match texMathCmd '\\boldsymbol{B}' conceal cchar=𝑩
    syntax match texMathCmd '\\boldsymbol{C}' conceal cchar=𝑪
    syntax match texMathCmd '\\boldsymbol{D}' conceal cchar=𝑫
    syntax match texMathCmd '\\boldsymbol{E}' conceal cchar=𝑬
    syntax match texMathCmd '\\boldsymbol{F}' conceal cchar=𝑭
    syntax match texMathCmd '\\boldsymbol{G}' conceal cchar=𝑮
    syntax match texMathCmd '\\boldsymbol{H}' conceal cchar=𝑯
    syntax match texMathCmd '\\boldsymbol{I}' conceal cchar=𝑰
    syntax match texMathCmd '\\boldsymbol{J}' conceal cchar=𝑱
    syntax match texMathCmd '\\boldsymbol{K}' conceal cchar=𝑲
    syntax match texMathCmd '\\boldsymbol{L}' conceal cchar=𝑳
    syntax match texMathCmd '\\boldsymbol{M}' conceal cchar=𝑴
    syntax match texMathCmd '\\boldsymbol{N}' conceal cchar=𝑵
    syntax match texMathCmd '\\boldsymbol{O}' conceal cchar=𝑶
    syntax match texMathCmd '\\boldsymbol{P}' conceal cchar=𝑷
    syntax match texMathCmd '\\boldsymbol{Q}' conceal cchar=𝑸
    syntax match texMathCmd '\\boldsymbol{R}' conceal cchar=𝑹
    syntax match texMathCmd '\\boldsymbol{S}' conceal cchar=𝑺
    syntax match texMathCmd '\\boldsymbol{T}' conceal cchar=𝑻
    syntax match texMathCmd '\\boldsymbol{U}' conceal cchar=𝑼
    syntax match texMathCmd '\\boldsymbol{V}' conceal cchar=𝑽
    syntax match texMathCmd '\\boldsymbol{W}' conceal cchar=𝑾
    syntax match texMathCmd '\\boldsymbol{X}' conceal cchar=𝑿
    syntax match texMathCmd '\\boldsymbol{Y}' conceal cchar=𝒀
    syntax match texMathCmd '\\boldsymbol{Z}' conceal cchar=𝒁

    syntax match texMathCmd '\\boldsymbol{\\alpha}' conceal cchar=𝜶
    syntax match texMathCmd '\\boldsymbol{\\beta}' conceal cchar=𝜷
    syntax match texMathCmd '\\boldsymbol{\\gamma}' conceal cchar=𝜸
    syntax match texMathCmd '\\boldsymbol{\\delta}' conceal cchar=𝜹
    syntax match texMathCmd '\\boldsymbol{\\epsilon}' conceal cchar=𝜺
    syntax match texMathCmd '\\boldsymbol{\\zeta}' conceal cchar=𝜻
    syntax match texMathCmd '\\boldsymbol{\\eta}' conceal cchar=𝜼
    syntax match texMathCmd '\\boldsymbol{\\theta}' conceal cchar=𝜽
    syntax match texMathCmd '\\boldsymbol{\\iota}' conceal cchar=𝜾
    syntax match texMathCmd '\\boldsymbol{\\kappa}' conceal cchar=𝜿
    syntax match texMathCmd '\\boldsymbol{\\lambda}' conceal cchar=𝝀
    syntax match texMathCmd '\\boldsymbol{\\mu}' conceal cchar=𝝁
    syntax match texMathCmd '\\boldsymbol{\\nu}' conceal cchar=𝝂
    syntax match texMathCmd '\\boldsymbol{\\xi}' conceal cchar=𝝌
    syntax match texMathCmd '\\boldsymbol{\\omicron}' conceal cchar=𝝄
    syntax match texMathCmd '\\boldsymbol{\\pi}' conceal cchar=𝝅
    syntax match texMathCmd '\\boldsymbol{\\rho}' conceal cchar=𝝆
    syntax match texMathCmd '\\boldsymbol{\\sigma}' conceal cchar=𝝈
    syntax match texMathCmd '\\boldsymbol{\\tau}' conceal cchar=𝝉
    syntax match texMathCmd '\\boldsymbol{\\upsilon}' conceal cchar=𝝇
    syntax match texMathCmd '\\boldsymbol{\\phi}' conceal cchar=φ
    syntax match texMathCmd '\\boldsymbol{\\chi}' conceal cchar=𝝃
    syntax match texMathCmd '\\boldsymbol{\\psi}' conceal cchar=𝝍
    syntax match texMathCmd '\\boldsymbol{\\omega}' conceal cchar=𝝎
    syntax match texMathCmd '\\lin' conceal cchar=ℓ
    syntax match texMathCmd '\\measfield' conceal cchar=𝕂
    syntax match texMathCmd '\\field' conceal cchar=ℝ 

    syntax region mdAtLink
          \ start='\[\[@' end='\]\]'
          \ contains=mdAtOpen,mdAtClose,mdAtFirst,mdAtRest
          \ concealends keepend

    syntax match mdAtOpen '\[\[' contained conceal cchar=[
    syntax match mdAtClose '\]\]' contained conceal cchar=]
    syntax match mdAtFirst '@\w\w\zs\w\+' contained conceal
    ]]

  --
  -- Copilot give me math bold C like blackboard for complex: 𝕔
  -- And reals: ℝ
  -- Additional syntax matches can be added here
  -- 𝝦 𝝧 𝝨 𝝩 𝝪 𝝫 𝝬 𝝭 𝝮
  --
end

-- vim.cmd [[
--     let g:mkdp_preview_options = {
--         \ 'mkit': {},
--         \ 'katex': {'macros': {"\\proj": "\\Pi", "\\bR": "\\mathbb{R}", "\\ker": "\\mathrm{ker}", "\\allone": "\\mathbb{1}", "\\indicator":"\\mathbb{1}", "\\minimize": "\\mathbb{minimize}", "\\maximize": "\\mathbb{maximize}", "\\argmin": "\\mathbb{argmin}", "\\argmax": "\\mathbb{argmax}", "\\range": "\\mathbb{range}", "\\prob": "\\mathbb{P}", "\\hull": "\\mathbb{H}", "\\Span": "\\mathbb{span}", "\\aff": "\\mathbb{aff}", "\\indep": "\perp\!\!\!\!\perp", "\\rank": "\\mathbb{rank}", "\\diag": "\\mathbb{diag}", "\\Diag":"\\mathbb{Diag}", "\\interior":"\\mathbb{int}", "\\measfield": "\\mathbb{C}", "\\field": "\\mathbb{R}"},},
--         \ 'uml': {},
--         \ 'maid': {},
--         \ 'disable_sync_scroll': 0,
--         \ 'sync_scroll_type': 'middle',
--         \ 'hide_yaml_meta': 1,
--         \ 'sequence_diagrams': {},
--         \ 'flowchart_diagrams': {},
--         \ 'content_editable': v:false,
--         \ 'disable_filename': 0,
--         \ 'toc': {}
--         \ }
--     ]]

-- Create an autocommand group for markdown conceal settings
-- local markdown_conceal_group = vim.api.nvim_create_augroup('MarkdownConceal', { clear = true })

-- Register autocommands to run the setup function on specific events and filetypes
-- vim.api.nvim_create_autocmd({ 'VimEnter', 'BufWinEnter' }, {
--   group = markdown_conceal_group,
--   pattern = '*.md',
--   callback = setup_custom_conceals,
-- })
