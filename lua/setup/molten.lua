vim.g.molten_output_virt_lines = false

local function get_save_file_name(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local save_dir = vim.fn.fnamemodify(bufname, ':p:h')
  local fname = vim.fn.fnamemodify(bufname, ':t:r') .. '.molten.json'
  return save_dir .. '/.' .. fname
end

local function stop_molten()
  vim.cmd 'MoltenDeinit'
  vim.keymap.set({ 'n', 'v' }, '<leader>mr', Start_molten, { desc = '[S]tart [M]olten', nowait = true })
  local bufnr = vim.api.nvim_get_current_buf()
  vim.keymap.set('n', '<leader>r', '<cmd>Make<cr>', { buffer = bufnr, silent = true })
end

local function jump_to_end()
  vim.cmd 'MoltenNextEnd'
  vim.cmd 'normal! zt'
end

local function jump_to_prev_end()
  vim.cmd 'MoltenPrevEnd'
  vim.cmd 'normal! zt'
end

function Start_molten()
  local bufnr = vim.api.nvim_get_current_buf()
  local full_path = get_save_file_name(bufnr)
  print(full_path)
  print(vim.fn.filereadable(full_path))
  if vim.fn.filereadable(full_path) == 1 then
    local success, err = pcall(function()
      vim.cmd('MoltenLoad ' .. full_path)
    end)
    if not success then
      vim.cmd 'MoltenInit sparse_adapted_denoising'
      vim.cmd('MoltenSave ' .. vim.fn.shellescape(full_path))
    end
  else
    vim.cmd 'MoltenInit sparse_adapted_denoising'
    vim.cmd('MoltenSave ' .. vim.fn.shellescape(full_path))
  end

  vim.keymap.set('n', '<leader>mc', ':MoltenEvaluateOperator<CR>', { nowait = true, buffer = bufnr, silent = true, desc = 'run operator selection' })
  vim.keymap.set(
    'n',
    '<leader>ml',
    ':MoltenLoad ' .. get_save_file_name(bufnr) .. '<CR>',
    { nowait = true, buffer = bufnr, silent = true, desc = 'run operator selection' }
  )
  vim.keymap.set('n', '<leader>rl', ':MoltenEvaluateLine<CR>', { buffer = bufnr, silent = true, desc = 'evaluate line' })
  vim.keymap.set('n', '<leader>rr', ':MoltenReevaluateCell<CR>', { nowait = true, buffer = bufnr, silent = true, desc = 're-evaluate cell' })
  vim.keymap.del('n', '<leader>r', { buffer = bufnr, silent = true })
  vim.keymap.set('v', '<leader>rr', ':<C-u>MoltenEvaluateVisual<CR>', { nowait = true, buffer = bufnr, silent = true, desc = 'evaluate visual selection' })
  vim.keymap.set('n', '<leader>oh', ':MoltenHideOutput<CR>', { buffer = bufnr, silent = true, desc = 'hide output' })
  vim.keymap.set('n', '<leader>os', ':noautocmd MoltenEnterOutput<CR>', { buffer = bufnr, silent = true, desc = 'show/enter output' })
  vim.keymap.set('n', '<C-c>', ':MoltenInterrupt<CR>', { nowait = true, buffer = bufnr, silent = true, desc = 'Interrupt Kernel' })
  vim.keymap.set('n', ']]', jump_to_end, { nowait = true, buffer = bufnr, silent = true, desc = 'Next molten chunk' })
  vim.keymap.set('n', '[[', jump_to_prev_end, { nowait = true, buffer = bufnr, silent = true, desc = 'Prev molten chunk' })
  vim.keymap.set('n', '<leader>mx', stop_molten, { nowait = true, buffer = bufnr, silent = true, desc = '[M]olten [D]einit' })

  vim.keymap.del({ 'n', 'v' }, '<leader>mr')

  -- Which-key integration (if available)
  require('which-key').add({
    { '<C-CR>', desc = 'Molten: Eval', mode = { 'n', 'v' } },
    { '<S-CR>', desc = 'Molten: Eval + Next', mode = { 'n', 'v' } },
    { '<leader>ro', group = '[R]un: Enter Output' },
  }, { buffer = bufnr })

  vim.api.nvim_create_autocmd('BufUnload', {
    buffer = bufnr, -- Targets only this buffer
    callback = stop_molten,
  })

  vim.api.nvim_create_autocmd('BufWritePost', {
    buffer = bufnr,
    callback = function()
      vim.cmd('MoltenSave ' .. get_save_file_name(bufnr), { silent = true })
    end,
  })
end

vim.keymap.set({ 'n', 'v' }, '<leader>mr', Start_molten, { desc = '[S]tart [M]olten', nowait = true })
