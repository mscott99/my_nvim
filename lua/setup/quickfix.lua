local qf_dir = vim.fn.expand '~/.config/my_lists/'
vim.fn.mkdir(qf_dir, 'p') -- Create the directory if it doesn't exist ("p" ensures parent dirs are created too)

-- Load saved quickfix lists
function AddCurrentFileToQF()
  local current_file = vim.fn.expand '%:p'
  local current_line = vim.fn.line '.'
  local qf_list = vim.fn.getqflist()
  local new_entry = {
    filename = current_file,
    lnum = current_line,
    text = current_file,
  }
  table.insert(qf_list, new_entry)
  vim.fn.setqflist(qf_list, 'r')
end
vim.keymap.set('n', '<leader>qa', AddCurrentFileToQF, { desc = '[Q]uickfix [A]dd' })

vim.keymap.set('n', '<leader>qc', '<cmd>cexpr []<cr>', { desc = '[Q]uickfix [C]lear' })

-- Function to view quickfix list in telescope
local function find_in_quickfixlist()
  require('telescope.builtin').quickfix({
    bufnr = vim.api.nvim_get_current_buf(),
  })
end

-- Set keymap to open quickfix list in telescope
vim.keymap.set('n', '<leader>fq', find_in_quickfixlist, { desc = '[F]ind in [Q]uickfix list' })

local builtin = require 'telescope.builtin'

local live_grep_qflist = function()
  local qflist = vim.fn.getqflist()
  local filetable = {}
  local hashlist = {}

  for _, value in pairs(qflist) do
    local name = vim.api.nvim_buf_get_name(value.bufnr)

    if name and not hashlist[name] then
      hashlist[name] = true
      table.insert(filetable, name)
    end
  end

  -- Configure live_grep with multiline support
  builtin.live_grep {
    search_dirs = filetable,
    use_regex = true,
    additional_args = function()
      return {
        "--multiline",        -- Enable multiline matching
        "--multiline-dotall", -- Make dot match newlines
        "-U"                  -- Enable unicode support
      }
    end
  }
end


vim.keymap.set('n', '<leader>sq', live_grep_qflist, { desc = '[S]earch [Q]uickfix list' })

-- Function to save the current quickfix list to a file
local function save_quickfix_list()
  -- Get the current quickfix list
  local qf_list = vim.fn.getqflist()

  if #qf_list == 0 then
    vim.notify('Quickfix list is empty, nothing to save', vim.log.levels.WARN)
    return
  end

  -- Open a temporary buffer to store the quickfix list
  local tmp_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(tmp_bufnr, 'buftype', 'nofile')

  -- Format each entry according to errorformat: "filename:lnum:col:text"
  local lines = {}
  for _, entry in ipairs(qf_list) do
    local filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)
    -- Convert to absolute path
    filename = vim.fn.fnamemodify(filename, ':p')
    local line = string.format("%s:%d:%d:%s",
      filename,
      entry.lnum or 1,
      entry.col or 1,
      entry.text or ""
    )
    table.insert(lines, line)
  end

  -- Write the formatted lines to the temporary buffer
  vim.api.nvim_buf_set_lines(tmp_bufnr, 0, -1, false, lines)

  -- Prompt for filename
  vim.ui.input({ prompt = 'Filename: ' }, function(filename)
    if not filename or filename == '' then
      vim.notify('No filename provided, aborting', vim.log.levels.WARN)
      vim.api.nvim_buf_delete(tmp_bufnr, { force = true })
      return
    end

    filename = filename:gsub('[/\\]', '_') .. '.qf'
    local filepath = qf_dir .. filename

    if vim.fn.filereadable(filepath) == 1 then
      vim.ui.input({
        prompt = string.format("File '%s' exists. Overwrite? (y/n): ", filename),
        default = 'y',
      }, function(response)
        if not response or response:lower() ~= 'y' then
          vim.notify('Save aborted', vim.log.levels.INFO)
          vim.api.nvim_buf_delete(tmp_bufnr, { force = true })
          return
        end
        -- Write buffer content to file
        local lines = vim.api.nvim_buf_get_lines(tmp_bufnr, 0, -1, false)
        local file = io.open(filepath, 'w')
        if file then
          file:write(table.concat(lines, '\n'))
          file:close()
          vim.notify('Quickfix list saved to ' .. filepath, vim.log.levels.INFO)
        else
          vim.notify('Failed to save quickfix list', vim.log.levels.ERROR)
        end
        vim.api.nvim_buf_delete(tmp_bufnr, { force = true })
      end)
    else
      -- Write buffer content to file
      local lines = vim.api.nvim_buf_get_lines(tmp_bufnr, 0, -1, false)
      local file = io.open(filepath, 'w')
      if file then
        file:write(table.concat(lines, '\n'))
        file:close()
        vim.notify('Quickfix list saved to ' .. filepath, vim.log.levels.INFO)
      else
        vim.notify('Failed to save quickfix list', vim.log.levels.ERROR)
      end
      vim.api.nvim_buf_delete(tmp_bufnr, { force = true })
    end
  end)
end

vim.keymap.set('n', '<leader>qs', save_quickfix_list, { desc = 'Save quickfix list' })

-- Required Telescope modules
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- Function to load a quickfix list using Telescope with delete capability
local function load_quickfix_list()
  -- Prepare functions for picker handling
  local function get_files()
    return vim.fn.glob(qf_dir .. "*.qf", true, true)
  end

  local function refresh_picker(prompt_bufnr)
    local files = get_files()
    if #files == 0 then
      vim.notify("No saved quickfix lists remain", vim.log.levels.WARN)
      actions.close(prompt_bufnr)
      return false
    end
    local picker = action_state.get_current_picker(prompt_bufnr)
    picker:refresh(finders.new_table({
      results = files,
      entry_maker = function(entry)
        local filename = vim.fn.fnamemodify(entry, ":t")
        return {
          value = entry,
          display = filename,
          ordinal = filename,
        }
      end,
    }), { reset_prompt = true })
    return true
  end

  -- Define delete action
  local function delete_selected_files(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selections = picker:get_multi_selection()
    if #selections == 0 then
      local entry = action_state.get_selected_entry()
      if entry then selections = { entry } end
    end
    if #selections == 0 then
      vim.notify("No file selected to delete", vim.log.levels.WARN)
      return
    end

    for _, selection in ipairs(selections) do
      local filepath = selection.value
      local ok, err = pcall(os.remove, filepath)
      if ok then
        vim.notify("Deleted " .. vim.fn.fnamemodify(filepath, ":t"), vim.log.levels.INFO)
      else
        vim.notify("Failed to delete " .. filepath .. ": " .. err, vim.log.levels.ERROR)
      end
    end

    refresh_picker(prompt_bufnr)
  end

  -- Initial check for files
  local files = get_files()
  if #files == 0 then
    vim.notify("No saved quickfix lists found in " .. qf_dir, vim.log.levels.WARN)
    return
  end

  -- Create Telescope picker
  pickers.new({}, {
    prompt_title = "Load Quickfix List (C-d to delete)",
    finder = finders.new_table({
      results = files,
      entry_maker = function(entry)
        local filename = vim.fn.fnamemodify(entry, ":t")
        return {
          value = entry,
          display = filename,
          ordinal = filename,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      -- Load action (<CR>)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if not selection then return end
        local filepath = selection.value
        actions.close(prompt_bufnr)
        
        -- Using cfile is ideal here because:
        -- 1. It handles the errorformat parsing automatically
        -- 2. It's built into vim and well-tested
        -- 3. It maintains consistency with vim's quickfix functionality
        -- 4. It handles file paths and line numbers robustly
        vim.cmd('cgetfile ' .. vim.fn.fnameescape(filepath))
        vim.notify("Quickfix list loaded from " .. filepath, vim.log.levels.INFO)
      end)

      -- Map delete action to <C-d>
      map({"i", "n"}, "<C-d>", delete_selected_files)

      return true -- Keep default mappings
    end,
  }):find()
end

-- Key mapping
vim.keymap.set("n", "<leader>ql", load_quickfix_list, { desc = "Load quickfix list with Telescope" })
