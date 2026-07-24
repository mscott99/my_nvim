local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local sorters = require 'telescope.sorters'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'

local VAULT = '/Users/matthewscott/Obsidian/myVault'
local BIN = vim.fn.expand '~/.local/bin/vault-search'

local function entry_maker(data)
  return {
    value = data,
    -- right-pad title to 60 chars so scores align in the picker column
    display = string.format('%-60s  %.3f', data.title or '', data.score or 0),
    ordinal = (data.title or '') .. ' ' .. (data.path or ''),
    path = data.path,
    filename = data.path,
  }
end

local M = {}

M.search = function(opts)
  opts = opts or {}
  vim.ui.input({ prompt = 'Vault search: ' }, function(query)
    if not query or query == '' then return end

    vim.system(
      { BIN, '--vault', VAULT, 'query', query, '--top', '20' },
      { text = true },
      function(result)
        vim.schedule(function()
          if result.code ~= 0 then
            vim.notify(
              'vault-search error: ' .. (result.stderr or ''),
              vim.log.levels.ERROR
            )
            return
          end

          local entries = {}
          for line in (result.stdout or ''):gmatch '[^\n]+' do
            local ok, data = pcall(vim.json.decode, line)
            if ok and data and data.path then
              table.insert(entries, data)
            end
          end

          if #entries == 0 then
            vim.notify('vault-search: no results', vim.log.levels.WARN)
            return
          end

          pickers
            .new(opts, {
              prompt_title = 'Vault: ' .. query,
              finder = finders.new_table {
                results = entries,
                entry_maker = entry_maker,
              },
              -- Empty sorter preserves semantic ranking; user can still type to
              -- fuzzy-filter within results via the generic sorter below.
              sorter = conf.generic_sorter(opts),
              attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)
                  local sel = action_state.get_selected_entry()
                  if sel and sel.path then
                    vim.cmd('edit ' .. vim.fn.fnameescape(sel.path))
                  end
                end)
                return true
              end,
            })
            :find()
        end)
      end
    )
  end)
end

vim.keymap.set('n', '<leader>fv', M.search, { desc = '[F]ind [V]ault (semantic)' })

return M
