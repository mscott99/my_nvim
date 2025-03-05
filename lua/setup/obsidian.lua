-- This script creates a telescope picker for embedded wikilinks in the current buffer
-- We'll focus on [[file]] style links that are prefixed with ! for embeds
-- Using telescope for better UX and consistency with obsidian.nvim

-- This implementation uses obsidian.nvim's built-in functionality to properly resolve links
-- and uses the async executor pattern to handle link resolution efficiently

local AsyncExecutor = require("obsidian.async").AsyncExecutor
local iter = require("obsidian.itertools").iter
local search = require "obsidian.search"
local enumerate = require("obsidian.itertools").enumerate
local log = require "obsidian.log"
local channel = require("plenary.async.control").channel

-- This implementation follows the same pattern as obsidian.commands.links
-- but specifically filters for embedded links (those starting with !)
local function get_embedded_files(client)
  local picker = client:picker()
  if not picker then
    log.err "No picker configured"
    return
  end

  -- Gather all unique raw links (strings) from the buffer.
  ---@type table<string, integer>
  local links = {}
  for lnum, line in enumerate(vim.api.nvim_buf_get_lines(0, 0, -1, true)) do
    -- Look for embedded wikilinks that start with ![[
    -- Match pattern: ![[anything except closing brackets]]
    local embed_pattern = "!%[%[([^%]]+)%]%]"
    for embed in line:gmatch(embed_pattern) do
      local link = "[[" .. embed .. "]]"  -- Reconstruct full wikilink format
      if not links[link] then
        links[link] = lnum
      end
    end
  end

  local executor = AsyncExecutor.new()

  executor:map(
    function(link)
      local tx, rx = channel.oneshot()

      ---@type obsidian.PickerEntry[]
      local entries = {}

      client:resolve_link_async(link, function(...)
        for res in iter { ... } do
          local icon, icon_hl
          if res.url ~= nil then
            icon, icon_hl = util.get_icon(res.url)
          end
          table.insert(entries, {
            value = link,
            display = res.name,
            filename = res.path and tostring(res.path) or nil,
            icon = icon,
            icon_hl = icon_hl,
            lnum = res.line,
            col = res.col,
          })
        end

        tx()
      end)

      rx()
      return unpack(entries)
    end,
    vim.tbl_keys(links),
    function(results)
      vim.schedule(function()
        -- Flatten entries.
        local entries = {}
        for res in iter(results) do
          for r in iter(res) do
            entries[#entries + 1] = r
          end
        end

        -- Sort by position within the buffer.
        table.sort(entries, function(a, b)
          return links[a.value] < links[b.value]
        end)

        -- Launch picker.
        picker:pick(entries, {
          prompt_title = "Links",
          callback = function(link)
            client:follow_link_async(link)
          end,
        })
      end)
    end
  )
end

-- Create a command to bind to keymap for telescope picker
vim.api.nvim_create_user_command("ObsidianEmbeddedFiles", function()
  -- This function accepts a client parameter, so we need to get the current client
  local obsidian = require("obsidian")
  local client = obsidian.get_client()
  if client then
    get_embedded_files(client)
  else
    vim.notify("No Obsidian client available", vim.log.levels.ERROR)
  end
end, {})

-- Set up the keymap
-- Using <leader>oe as a mnemonic for 'obsidian embedded'
vim.keymap.set('n', '<leader>oe', ':ObsidianEmbeddedFiles<CR>', {
  noremap = true, 
  silent = true,
  desc = "[O]bsidian [E]mbed"
})
