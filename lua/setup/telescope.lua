-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    prompt_prefix = ' ',
    selection_caret = ' ',
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')

-- Telescope live_grep in git root
-- Function to find the git root directory based on the current buffer's path
local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == '' then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

-- Custom live_grep function to search in git root
local function live_grep_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').live_grep {
      cwd = { git_root },
    }
  end
end

local function hidden_files_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').find_files {
      search_dirs = { git_root },
      hidden = true,
      no_ignore = true,
    }
  end
end

local function grep_hidden_files_git_root()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').find_files {
      search_dirs = { git_root },
      hidden = true,
      no_ignore = true,
    }
  end
end

local function oldfiles_in_git_dir()
  local git_root = find_git_root()
  if git_root then
    require('telescope.builtin').oldfiles {
      cwd = git_root ,
      only_cwd = true,
    }
  end
end

vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end



vim.keymap.set('n', '<leader>fp', function()
  require('telescope.builtin').find_files { cwd = require('lazy.core.config').options.root }
end, { desc = 'Find Plugin File' })
vim.keymap.set('n', '<leader>ss', '<cmd>Telescope lsp_document_symbols<CR>', { desc = '[S]earch Document [S]ymbols' })
vim.keymap.set('n', '<leader>sS', '<cmd>Telescope lsp_workspace_symbols<CR>', { desc = '[S]earch Workspace [S]ymbols' })
vim.keymap.set('n', '<leader>sp', '<cmd>Telescope <CR>', { desc = '[S]earch [P]ickers' })

local search_dirs = {
  '~/.config/skhd/',
  '~/.config/nvim/',
  '~/.config/kickstarted_nvim/',
  '~/.config/skhd/',
  '~/.config/yabai/',
  '~/.config/export_obsidian/',
  '~/.config/alacritty/',
}
vim.keymap.set('n', '<leader>fc', function()
  require('telescope.builtin').find_files {
    search_dirs = search_dirs, -- still missing the files at the root of dotfiles folder
  }
end, { desc = '[F]ind [C]onfig File' })
vim.keymap.set('n', '<leader>sc', function()
  require('telescope.builtin').live_grep {
    search_dirs = search_dirs, -- still missing the files at the root of dotfiles folder
  }
end, { desc = '[S]earch [C]onfig File' })
vim.keymap.set('n', '<leader>fk', require('telescope.builtin').keymaps , { desc = '[T]elescope [K]eymaps'})
vim.keymap.set('n', '<leader>sg', function() require('telescope.builtin').live_grep({cwd = find_git_root()}) end, { desc = '[S]earch by [G]rep on Git Root of Current File' })
vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').find_files({cwd = find_git_root()}) end, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fh', hidden_files_git_root, { desc = '[F]ind [H]idden files' })
vim.keymap.set('n', '<leader>sh', grep_hidden_files_git_root, { desc = '[S]earch [H]idden files' })
vim.keymap.set('n', '<leader>fr', require("telescope.builtin").oldfiles, { desc = '[F]ind [R]ecent files' })
vim.keymap.set('n', '<leader>fR', oldfiles_in_git_dir, { desc = '[F]ind [R]ecent files' })
-- find buffers
vim.keymap.set('n', '<leader>fb', require('telescope.builtin').buffers, {desc = '[F]ind [B]uffers'})
--TODO: also add pickers which include hidden files.

vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
-- vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
-- vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })
