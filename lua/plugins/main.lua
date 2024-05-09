-- core plugins
return {
  -- NOTE: First, some plugins that don't require any configuration

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },
  {
    "benfowler/telescope-luasnip.nvim",
    event = "InsertEnter",
    module = "telescope._extensions.luasnip",
    config = function()
      require('telescope').load_extension('luasnip')
    end
  },
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>uu', '<cmd>UndotreeToggle<CR>', desc = 'Undo Tree' },
    },
  },
  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
      {
        "microsoft/python-type-stubs",
        cond = false
      }
    },
  },
  {
    'stevearc/oil.nvim',
    -- Optional dependencies
    cmd = {'Oil'},
    opts = {
      default_file_explorer = true,
    },
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    'ThePrimeagen/harpoon',
    dependencies = 'nvim-lua/plenary.nvim',
    event = 'VeryLazy',
    -- keys = {
    --  '<leader>a',
    --  '<C-e>',
    --  '<leader>j',
    --  '<leader>k',
    --  '<leader>h',
    --  '<leader>l',
    -- },
    config = function()
      local mark = require 'harpoon.mark'
      local ui = require 'harpoon.ui'

      vim.keymap.set('n', '<leader>a', mark.add_file, {desc = "mark file"})
      vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu)

      vim.keymap.set('n', '<leader>j', function()
        ui.nav_file(1)
      end, { desc = 'Go to first harpooned file' })
      vim.keymap.set('n', '<leader>k', function()
        ui.nav_file(2)
      end, { desc = 'Go to second harpooned file' })
      vim.keymap.set('n', '<leader>h', function()
        ui.nav_file(3)
      end, { desc = 'Go to third harpooned file' })
      vim.keymap.set('n', '<leader>l', function()
        ui.nav_file(4)
      end, { desc = 'Go to fourth harpooned file' })
    end,
  },
  {
    'ggandor/leap.nvim',
    lazy = false,
    config = function(_, opts)
      require('leap').add_default_mappings(true) -- will overwrite the s key.
      -- vim.keymap.set({'n'}, "gs", function()
      --   require("leap").leap {
      --     target_windows = vim.tbl_filter(function(win)
      --       return vim.api.nvim_win_get_config(win).focusable
      --     end, vim.api.nvim_tabpage_list_wins(0)),
      --   }
      -- end, { noremap = true, silent = true })
    end,
  },
  {
    'machakann/vim-sandwich',
    enabled = true,
    event = 'VeryLazy',
    config = function()
      -- local personnal_maps = require("custom.configs.sandwich_recipes")
      -- vim.g['sandwich#recipes'] = vim.tbl_extend(vim.deepcopy(vim.g['sandwich#default_recipes']), personnal_maps)
      -- print(personnal_maps)
      --
      -- Do not shadow the "s" keybind
      vim.cmd [[runtime macros/sandwich/keymap/surround.vim
        nunmap sa
        xunmap sa
        ounmap sa
        nmap gsa <Plug>(sandwich-add)
        xmap gsa <Plug>(sandwich-add)
        omap gsa <Plug>(sandwich-add)
        nunmap sr
        xunmap sr
        nmap gsr <Plug>(sandwich-replace)
        xmap gsr <Plug>(sandwich-replace)
        nunmap srb
        nmap gsrb <Plug>(sandwich-replace-auto)
        nunmap sd
        xunmap sd
        nmap gsd <Plug>(sandwich-delete)
        xmap gsd <Plug>(sandwich-delete)
        nunmap sdb
        nmap gsdb <Plug>(sandwich-delete-auto)
      ]]
      vim.cmd [[
        let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
        let g:sandwich#recipes += [{'buns': ['\left(', '\right)'], 'input':['P']}]
        let g:sandwich#recipes += [{'buns': ['\left[', '\right]'], 'input':['B']}]
        let g:sandwich#recipes += [{'buns': ['\|', '\|'], 'input':['n']}]
        let g:sandwich#recipes += [{'buns': ['\{', '\}'], 'input':['s']}]
        let g:sandwich#recipes += [{'buns': ['\left\{', '\right\}'], 'input':['S']}]
        let g:sandwich#recipes += [{'buns': ['\left\|', '\right\|'], 'input':['N']}]
        let g:sandwich#recipes += [{'buns': ["[[", "]\]"], 'input':['w']}]
        let g:sandwich#recipes += [{'buns': ['\langle ', '\rangle '], 'input':['a']}]
        let g:sandwich#recipes += [{'buns': ['\left\langle ', '\right\rangle'], 'input':['A']}]
        let g:sandwich#recipes += [{'buns': ['\left| ', '\right|'], 'input':['L']}]
      ]]
    end,
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '｜' },
        change = { text = '｜' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>ghs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>ghr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>ghs', gs.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>ghr', gs.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>ghS', gs.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>ghu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>ghR', gs.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>ghp', gs.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>ghb', function()
          gs.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>ghd', gs.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>ghD', function()
          gs.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gs.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },
  {
    'kdheepak/lazygit.nvim',
    -- optional for floating window border decoration
    --
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
    },
  },
  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'gruvbox'
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = require('gruvbox').palette.dark0 })
    end,
  },
  {
    'folke/persistence.nvim',
    -- event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    event = 'VimEnter', -- this will only start session saving when an actual file was opened
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = {
      'folke/persistence.nvim',
    },
    opts = function()
      local logo = [[
           ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
           ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z    
           ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z       
           ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z         
           ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║           
           ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝           
      ]]

      logo = string.rep('\n', 8) .. logo .. '\n\n'

      local opts = {
        theme = 'doom',
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, '\n'),
          -- stylua: ignore
          center = {
            { action = "Telescope find_files",                                     desc = " Find file",       icon = " ", key = "f" },
            { action = "ene | startinsert",                                        desc = " New file",        icon = " ", key = "n" },
            { action = "Telescope oldfiles",                                       desc = " Recent files",    icon = " ", key = "r" },
            { action = "Telescope live_grep",                                      desc = " Find text",       icon = " ", key = "g" },
            { action = 'lua require("persistence").load()',                        desc = " Restore Session", icon = " ", key = "s" },
            { action = "Lazy",                                                     desc = " Lazy",            icon = "󰒲 ", key = "l" },
            { action = "qa",                                                       desc = " Quit",            icon = " ", key = "q" },
          },
          footer = function()
            local stats = require('lazy').stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
        button.key_format = '  %s'
      end

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'DashboardLoaded',
          callback = function()
            require('lazy').show()
          end,
        })
      end

      return opts
    end,
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },
  {
    "benfowler/telescope-luasnip.nvim",
    dependencies = {
      'L3MON4D3/LuaSnip',
      'nvim-telescope/telescope.nvim',
    },
    cmd = "Telescope luasnip",
    config = function()
      require('telescope').load_extension('luasnip')
    end
  },
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
  { "nvim-treesitter/nvim-treesitter-textobjects" },
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}
