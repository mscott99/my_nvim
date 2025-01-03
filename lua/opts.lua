-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

vim.g.autoformat = false
-- vim.opt.spelllang = 'en_us'
-- vim.opt.spell = true
vim.cmd([[
      filetype plugin on
      set noswapfile
      " let g:lua_snippets_path=$XDG_CONFIG_HOME""/snippets/"
      set conceallevel=2
      let g:vim_markdown_conceal = 2
      let g:vim_markdown_math = 1
      let g:vim_markdown_frontmatter = 1
      au BufRead,BufNewFile *.typ                
      set efm+=,%f\|%l\ col\ %c\|%m,%f
      set colorcolumn=70
      ]])


-- gets confused with sql. Even this does not seem to work, so I
-- added an autocommand above instead.
-- vim.g.filetype_typ = "typst"
-- the below is not working.
-- vim.cmd [[let g:vimtex_syntax_custom_cmds = [
--           \ {'name': 'R', 'mathmode': 0, 'concealchar': 'ℝ'},
--           \]
--           ]]



-- Set highlight on search
vim.o.hlsearch = true

-- vim.o.concealcursor= "nc"

vim.o.cursorline = true

-- Make line numbers default
vim.wo.number = true

vim.wo.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true
