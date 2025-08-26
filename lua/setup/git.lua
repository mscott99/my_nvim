--- Sets up a 3-way merge diff view in two separate tabs for a conflicted file.
--
--  * Tab 1: Diffs the common ancestor (stage 1) against "our" version (stage 2).
--  * Tab 2: Diffs "our" version (stage 2) against "their" version (stage 3).
--
--  This function should be called from a buffer with a file in a merge conflict state.
--

function SetupMergeDiffs()
  -- 1. Ensure fugitive.vim is available
  if vim.fn.exists(':G') == 0 then
    vim.notify('Error: fugitive.vim plugin is not installed!', vim.log.levels.ERROR)
    return
  end

  -- 2. Get the full path of the current file
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then
    vim.notify('Warning: No file in the current buffer.', vim.log.levels.WARN)
    return
  end

  -- Escape the filepath to handle special characters correctly
  local escaped_filepath = vim.fn.fnameescape(filepath)

  -- 3. Create the first tab: Ancestor vs. Ours
  vim.cmd('tabnew')
  vim.cmd('e' .. escaped_filepath)
  vim.cmd('Gedit :2:' .. escaped_filepath)        -- Open "our" version (stage 2)
  vim.cmd('Gvdiffsplit :1:' .. escaped_filepath)  -- Diff with the common ancestor (stage 1)
  vim.cmd('wincmd h')                             -- Focus on the left pane ("ours")
  vim.cmd('wincmd v')
  vim.cmd("Gedit %")

  vim.cmd('tabnew')
  vim.cmd('e' .. escaped_filepath)
  vim.cmd('Gedit :3:' .. escaped_filepath)        -- Open "our" version (stage 2) again
  vim.cmd('Gvdiffsplit :1:' .. escaped_filepath)  -- Diff with "their" version (stage 3)
  vim.cmd('wincmd h')                             -- Focus on the left pane ("ours")
  vim.cmd('wincmd v')
  vim.cmd("Gedit %")
  -- vim.cmd("Gedit %")

  -- 5. Return to the first of the two new tabs to start resolving
  vim.cmd('tabprevious')
  vim.notify('Created 2 tabs for merge conflict resolution.', vim.log.levels.INFO)
end

-- Define user commands
vim.api.nvim_create_user_command('BetterMergeDiff', SetupMergeDiffs, {})
-- vim.api.nvim_create_user_command('UndoBetterMergeDiff', M.undo_better_merge_diff, {})

return M
