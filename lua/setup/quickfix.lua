local qf_dir = vim.fn.expand '~/.config/my_lists/'
vim.fn.mkdir(qf_dir, 'p') -- Create the directory if it doesn't exist ("p" ensures parent dirs are created too)

local function save_to_file(filepath, qf_list)
  -- Convert the quickfix list to a JSON string
  local json_data = vim.fn.json_encode(qf_list)

  -- Write to the file
  local ok, err = pcall(function()
    local file = io.open(filepath, 'w')
    if not file then
      error('Could not open file for writing: ' .. filepath)
    end
    file:write(json_data)
    file:close()
  end)

  if ok then
    vim.notify('Quickfix list saved to ' .. filepath, vim.log.levels.INFO)
  else
    vim.notify('Failed to save quickfix list: ' .. err, vim.log.levels.ERROR)
  end
end -- Define the directory for storing quickfix lists

-- Function to save the current quickfix list to a file
local function save_quickfix_list()
  -- Get the current quickfix list
  local qf_list = vim.fn.getqflist()

  if #qf_list == 0 then
    vim.notify('Quickfix list is empty, nothing to save', vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = 'Filename: ' }, function(filename)
    if not filename or filename == '' then
      vim.notify('No filename provided, aborting', vim.log.levels.WARN)
      return
    end
    filename = filename:gsub('[/\\]', '_') .. '.json'
    local filepath = qf_dir .. filename

    if vim.fn.filereadable(filepath) == 1 then
      vim.ui.input({
        prompt = string.format("File '%s' exists. Overwrite? (y/n): ", filename),
        default = 'n',
      }, function(response)
        if not response or response:lower() ~= 'y' then
          vim.notify('Save aborted', vim.log.levels.INFO)
          return
        end
        save_to_file(filepath, qf_list)
      end)
    else
      save_to_file(filepath, qf_list)
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
  local function get_files()
    return vim.fn.glob(qf_dir .. "*.json", true, true)
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

  -- Define the delete action as a reusable function
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

        local ok, data = pcall(function()
          local file = io.open(filepath, "r")
          if not file then error("Could not open file: " .. filepath) end
          local content = file:read("*a")
          file:close()
          return vim.fn.json_decode(content)
        end)

        if ok then
          vim.fn.setqflist(data, "r")
          vim.notify("Quickfix list loaded from " .. filepath, vim.log.levels.INFO)
        else
          vim.notify("Failed to load quickfix list: " .. data, vim.log.levels.ERROR)
        end
      end)

      -- Map delete action to <C-d> for both insert and normal modes
      map({"i", "n"}, "<C-d>", function()
        delete_selected_files(prompt_bufnr)
      end)

      return true -- Keep default mappings
    end,
  }):find()
end

-- Key mapping
vim.keymap.set("n", "<leader>ql", load_quickfix_list, { desc = "Load quickfix list with Telescope" })
