-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  {
    'mxsdev/nvim-dap-vscode-js',
    lazy=true,
    dependencies = { 'microsoft/vscode-js-debug' },
    opts = { adapters = { 'pwa-node' }, debugger_path = '/Users/matthewscott/.local/share/my_nvim/lazy/vscode-js-debug' },
    -- do not clean, built manually.
    -- 	'mfussenegger/nvim-dap',
    -- 	{
    -- 'microsoft/vscode-js-debug',
    --built manually
    -- build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
    -- },
    -- },
  },
  {
    -- NOTE: Yes, you can install new plugins here!

    'mfussenegger/nvim-dap',
    lazy = true,
    -- NOTE: And you can specify dependencies as well
    dependencies = {
      -- Creates a beautiful debugger UI
      'rcarriga/nvim-dap-ui',

      -- Required dependency for nvim-dap-ui
      'nvim-neotest/nvim-nio',

      -- Installs the debug adapters for you
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',

      -- Add your own debuggers here
      'leoluz/nvim-dap-go',

      'jbyuki/one-small-step-for-vimkind',

      'mxsdev/nvim-dap-vscode-js',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      dap.configurations.lua = {
        {
          type = 'nlua',
          request = 'attach',
          name = 'Attach to running Neovim instance',
        },
      }

      dap.adapters.nlua = function(callback, config)
        callback { type = 'server', host = config.host or '127.0.0.1', port = config.port or 8086 }
      end

      vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: Start/Continue' })
      -- vim.keymap.set('v', '<leader>dc', dap_python.debug_selection, { desc = 'Debug selected code' })
      vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<leader>ds', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<leader>do', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>dp', dap.terminate, { desc = 'Debug: Terminate' })
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })

      vim.keymap.set('n', '<leader>dq', [[:lua require"osv".launch({port = 8086})<CR>]], { noremap = true, desc = '[D]ebug [N]eovim [S]erve' })

      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })

      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      vim.keymap.set('n', '<leader>dut', dapui.toggle, { desc = 'Debug: See last session result.' })

      vim.keymap.set({ 'n', 'v' }, '<leader>dh', dapui.eval , { noremap = true, silent = true })

      require('mason-nvim-dap').setup {
        -- Makes a best effort to setup the various debuggers with
        -- reasonable debug configurations
        automatic_installation = true,

        -- You can provide additional configuration to the handlers,
        -- see mason-nvim-dap README for more information
        handlers = {},

        -- You'll need to check that you have the required things installed
        -- online, please don't ask me how to install them :)
        ensure_installed = {
          -- Update this to ensure that you have the debuggers for the langs you want
          -- 'delve',
        },
      }

      -- Basic debugging keymaps, feel free to change to your liking!
      -- vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      -- vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      -- vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      -- vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      -- vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }


      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- require"dap-vscode-js".setup{adapters={'pwa-node'}, debugger_path = '/Users/matthewscott/.local/share/my_nvim/lazy/vscode-js-debug'}

      -- require('dap-vscode-js').setup {
      --   -- node_path = 'node', -- Path of node executable. Defaults to $NODE_PATH, and then "node"
      --   debugger_path = '/Users/matthewscott/.local/share/my_nvim/lazy/vscode-js-debug', -- Path to vscode-js-debug installation.
      --   -- debugger_cmd = { 'js-debug-adapter' }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
      --   adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }, -- which adapters to register in nvim-dap
      --   -- adapters = { 'pwa-node' }, -- which adapters to register in nvim-dap
      --   -- log_file_path = '(stdpath cache)/dap_vscode_js.log', -- Path for file logging
      --   log_file_level = false, -- Logging level for output to file. Set to false to disable file logging.
      --   log_console_level = vim.log.levels.ERROR, -- Logging level for output to console. Set to false to disable console output.
      -- }

      for _, language in ipairs { 'typescript', 'javascript' } do
        require('dap').configurations[language] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Debug Jest Tests',
            -- trace = true, -- include debugger info
            runtimeExecutable = 'node',
            runtimeArgs = {
              './node_modules/jest/bin/jest.js',
              '--runInBand',
            },
            rootPath = '${workspaceFolder}',
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
            internalConsoleOptions = 'neverOpen',
          },
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
        }
      end
    end,
  },
}
