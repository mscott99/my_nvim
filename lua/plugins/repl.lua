local start_repl = function()
  -- start based on filetype
  local filetype = vim.bo.filetype
  if filetype == "python" then
    vim.cmd([[TermExec cmd='source ./venv/bin/activate; python -m IPython --no-autoindent --matplotlib']])
  elseif filetype == "julia" then
    vim.cmd([[TermExec cmd='julia --project']])
  else
    vim.cmd([[TermExec cmd='echo "No REPL for this filetype"']])
  end
end

local trim_spaces = false
vim.keymap.set({ "n", "v" }, "<leader>R", start_repl, { desc = "start repl" })
vim.keymap.set("n", "<leader>r", function()
  require("toggleterm").send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
  vim.cmd("normal! j")
end)
vim.keymap.set({ "n", "i" }, "®", function()
  require("toggleterm").send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
  vim.cmd("normal! j")
end)

vim.keymap.set("v", "<leader>r", function()
  local tog = require("toggleterm")
  if vim.api.nvim_get_mode().mode == "v" then
    tog.send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })
  elseif vim.api.nvim_get_mode().mode == "V" then
    tog.send_lines_to_terminal("visual_lines", trim_spaces, { args = vim.v.count })
  end
  vim.cmd("normal! `>") -- move to end of visual selection
end)

return {
  {
    "akinsho/toggleterm.nvim",
    enabled = true,
    version = "*",
    config = true,
  },
  -- {
  --   "jpalardy/vim-slime",
  --   enabled = false,
  --   init = function()
  --     vim.b["quarto_is_" .. "python" .. "_chunk"] = false
  --     Quarto_is_in_python_chunk = function()
  --       require("otter.tools.functions").is_otter_language_context("python")
  --     end
  --
  --     vim.cmd([[
  --     let g:slime_dispatch_ipython_pause = 100
  --     function SlimeOverride_EscapeText_quarto(text)
  --     call v:lua.Quarto_is_in_python_chunk()
  --     if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk || (exists('b:quarto_is_r_mode') && !b:quarto_is_r_mode)
  --     return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
  --     else
  --     return a:text
  --     end
  --     endfunction
  --     ]])
  --
  --     local function mark_terminal()
  --       vim.g.slime_last_channel = vim.b.terminal_job_id
  --       vim.print(vim.g.slime_last_channel)
  --     end
  --
  --     local function set_terminal()
  --       vim.b.slime_config = { jobid = vim.g.slime_last_channel }
  --     end
  --
  --     vim.b.slime_cell_delimiter = "# %%"
  --
  --     -- slime, neovvim terminal
  --     vim.g.slime_target = "neovim"
  --     vim.g.slime_python_ipython = 1
  --
  --     -- -- slime, tmux
  --     -- vim.g.slime_target = 'tmux'
  --     -- vim.g.slime_bracketed_paste = 1
  --     -- vim.g.slime_default_config = { socket_name = "default", target_pane = ".2" }
  --
  --     local function toggle_slime_tmux_nvim()
  --       if vim.g.slime_target == "tmux" then
  --         pcall(function()
  --           vim.b.slime_config = nil
  --           vim.g.slime_default_config = nil
  --         end)
  --         -- slime, neovvim terminal
  --         vim.g.slime_target = "neovim"
  --         vim.g.slime_bracketed_paste = 0
  --         vim.g.slime_python_ipython = 1
  --       elseif vim.g.slime_target == "neovim" then
  --         pcall(function()
  --           vim.b.slime_config = nil
  --           vim.g.slime_default_config = nil
  --         end)
  --         -- -- slime, tmux
  --         vim.g.slime_target = "tmux"
  --         vim.g.slime_bracketed_paste = 1
  --         vim.g.slime_default_config = { socket_name = "default", target_pane = ".2" }
  --       end
  --     end
  --
  --     require("which-key").register({
  --       ["<leader>cm"] = { mark_terminal, "mark terminal" },
  --       ["<leader>cs"] = { set_terminal, "set terminal" },
  --       ["<leader>ct"] = { toggle_slime_tmux_nvim, "toggle tmux/nvim terminal" },
  --     })
  --   end,
  -- },
}
