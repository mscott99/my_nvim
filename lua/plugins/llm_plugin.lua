return {
  {
    'gsuuon/model.nvim',
    cmd = { 'M', 'Model', 'Mchat' },
    init = function()
      vim.filetype.add { extension = { mchat = 'mchat' } }
    end,
    ft = 'mchat',
    keys = {
      { '<C-m>d', ':Mdelete<cr>', mode = 'n' },
      { '<C-m>s', ':Mselect<cr>', mode = 'n' },
      { '<C-m><space>', ':Mchat<cr>', mode = 'n' },
    },
    config = function()
      local claude = require 'model.providers.anthropic'
      local starters = require 'model.prompts.starters'
      local mode = require('model').mode
      -- local util = require('model.util')
      -- local async = require('model.util.async')
      -- local prompts = require('model.util.prompts')
      -- local extract = require('model.prompts.extract')
      -- local consult = require('model.prompts.consult')
      require('model').setup {
        chats = {
          claude_chat = {
            provider = claude,
            system = 'You are a helpful assistant for note-taking and prose editing. When referring to files notes in my Obsidian vault (~/Obsidian/myVault/), do it with wikilinks [[...]] with the name of the file as the address, without the ".md", and without the directories in which they are. Put headers for specific sections, and line numbers (the line numbers should not be inside the wikilink).',
            create = function()
              return ''
            end,
            run = function(messages, config)
              local msg_array = {}
              -- Add user and assistant messages only
              -- local system_msg = config.system
              return {
                system = config.system, -- Top-level system parameter
                messages = messages,
                model = 'claude-2',
                max_tokens = 256,
                temperature = 0.5,
                top_p = 0.95,
              }
            end,
          },
          grok_chat = {
            provider = claude, -- We'll reuse claude's SSE handling
            system = 'You are a helpful assistant. You are confident in your answers and strive to share insightful information. You aim to provide thorough explanations while remaining concise.',
            create = function()
              return ''
            end,
            run = function(messages, config)
              -- Comments: Based on the Grok API info provided, we need to:
              -- - Change the endpoint/auth
              -- - Update model name
              -- - Keep compatible parameters
              return {
                system = config.system,
                messages = messages,
                model = 'grok-3', -- Using latest model
                max_tokens = 4096, -- Grok-3's typical context length
                temperature = 0.7, -- Slightly higher for more creative responses
                top_p = 0.95,
              }
            end,
          },
        },
        prompts = {
          minor_prose = {
            provider = claude,
            mode = mode.INSERT_OR_REPLACE,
            options = {
              headers = {
                ['anthropic-beta'] = 'max-tokens-3-5-sonnet-2024-07-15',
              },
              trim_code = true,
            },
            params = {
              max_tokens = 8192,
              model = 'claude-3-5-sonnet-latest',
              system = 'You are an academic writer and an applied mathematician. You know english grammar very well. You only use fancy words if their meaning is accurate and helpful, and you match the style of the surrounding text. When replacing text: unless modifying the surrounding text, keep newlines where they are: your changes will be diffed with the original. Each change should be discrete and easily understandable from a line-wise diff. Feel free to make larger changes if they constitute real improvements. Be honest. You improve the text in the manner specified by the user, using only the previous instructions as a baseline. Respond only with a markdown code block, with markdown content inside the code block.',
            },
            builder = function(input, context)
              local format = require 'model.format.claude'

              local theprompt = vim.tbl_extend('force', context.selection and format.build_replace(input, context) or format.build_insert(context), {
                stop_sequences = { '\n```' },
              })
              return theprompt
            end,
          },
          qf_prose = {
            provider = claude,
            mode = mode.INSERT_OR_REPLACE,
            options = {
              headers = {
                ['anthropic-beta'] = 'max-tokens-3-5-sonnet-2024-07-15',
              },
              trim_code = true,
            },
            params = {
              max_tokens = 8192,
              model = 'claude-3-5-sonnet-latest',
              system = 'You are an academic writer and an applied mathematician. You know english grammar very well. You only use fancy words if their meaning is accurate and helpful, and you match the style of the surrounding text. When replacing text: unless modifying the surrounding text, keep newlines where they are: your changes will be diffed with the original. Each change should be discrete and easily understandable from a line-wise diff. Be honest. Feel free to make larger changes if they constitute real improvements.',
            },
            builder = function(input, context)
              local format = require 'model.format.claude'
              qf_context = require('model.util.qflist').get_text()
              if qf_context ~= '' then
                context.args = 'Claude, here is relevant context from other files:\n' .. qf_context .. context.args
              end

              local theprompt = vim.tbl_extend('force', context.selection and format.build_replace(input, context) or format.build_insert(context), {
                stop_sequences = { '\n```' },
              })
              return theprompt
            end,
          },
          code_context = {
            provider = claude,
            mode = mode.INSERT_OR_REPLACE,
            options = {
              headers = {
                ['anthropic-beta'] = 'max-tokens-3-5-sonnet-2024-07-15',
              },
              trim_code = true,
            },
            params = {
              max_tokens = 8192,
              model = 'claude-3-5-sonnet-latest',
              system = 'You are an expert coder and an applied mathematician. You know python and lua in detail. In python, you like to build experiments by putting them as rows of a dataframe. You prioritize plotting with seaborne from dataframes. In lua, you are great at making neovim configs that are simple. You do not add any additional features than what is required, unless it is error checking. If you think you need more context, say so inside of comments inside the code you return.',
            },
            builder = function(input, context)
              local format = require 'model.format.claude'
              qf_context = require('model.util.qflist').get_text()
              if qf_context ~= '' then
                context.args = 'Claude, here is relevant context from other files:\n' .. qf_context .. context.args
              end

              local theprompt = vim.tbl_extend('force', context.selection and format.build_replace(input, context) or format.build_insert(context), {
                stop_sequences = { '\n```' },
              })
              return theprompt
            end,
          },
          claude_it = {
            provider = claude,
            mode = mode.INSERT_OR_REPLACE,
            options = {
              headers = {
                ['anthropic-beta'] = 'max-tokens-3-5-sonnet-2024-07-15',
              },
              trim_code = true,
            },
            params = {
              max_tokens = 8192,
              model = 'claude-3-5-sonnet-latest',
              system = 'You are an expert programmer. Provide code which should go between the before and after blocks of code. Respond only with a markdown code block. Use comments within the code if explanations are necessary. If the code you want to write is longer than 8192 tokens, then write descriptive pseudocode instead, so that you can deal with each item in seperate prompts later, replacing each one.',
            },
            builder = function(input, context)
              local format = require 'model.format.claude'

              local theprompt = vim.tbl_extend('force', context.selection and format.build_replace(input, context) or format.build_insert(context), {
                -- TODO this makes it impossible to get markdown in the response content
                -- eventually we may want to allow markdown in the code-fenced response
                stop_sequences = { '```' },
              })
              return theprompt
            end,
          },
          improve = {
            provider = claude,
            mode = 'replace', -- Replaces selection or buffer
            builder = function(input, context) -- Note: run, not builder, aligns with chat style
              return {
                system = 'You are a great coder, improving code in a straightforward way. Provide only the modified code, the rest of your comments will be discarded.',
                messages = {
                  { role = 'user', content = 'Suggest an improved version of this code:\n```lua\n' .. input .. '\n```' },
                },
                model = 'claude-2',
                max_tokens = 256,
                temperature = 0.5,
                top_p = 0.95,
              }
            end,
            transform = function(response) -- Optional: Extract code block
              local code = response:match '```lua\n(.-)\n```'
              return code or response
            end,
          },
        },
      }
    end,
  },
  -- {
  --   'yetone/avante.nvim',
  --   event = 'VeryLazy',
  --   lazy = false,
  --   version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  --   opts = {
  --     -- add any opts here
  --     -- for example
  --     provider = 'claude',
  --     auto_suggestions_provider = 'claude',
  --     cursor_applying_provider = nil, -- The provider used in the applying phase of Cursor Planning Mode, defaults to nil, when nil uses Config.provider as the provider for the applying phase
  --     claude = {
  --       endpoint = 'https://api.anthropic.com',
  --       model = 'claude-3-5-sonnet-20241022',
  --       temperature = 0,
  --       max_tokens = 4096,
  --     },
  --     behaviour = {
  --       auto_suggestions = false, -- Experimental stage
  --       auto_set_highlight_group = true,
  --       auto_set_keymaps = true,
  --       auto_apply_diff_after_generation = false,
  --       support_paste_from_clipboard = false,
  --       minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
  --       enable_token_counting = true, -- Whether to enable token counting. Default to true.
  --       enable_cursor_planning_mode = true, -- Whether to enable Cursor Planning Mode. Default to true.
  --     },
  --     mappings = {
  --       --- @class AvanteConflictMappings
  --       diff = {
  --         ours = 'co',
  --         theirs = 'ct',
  --         all_theirs = 'ca',
  --         both = 'cb',
  --         cursor = 'cc',
  --         next = ']x',
  --         prev = '[x',
  --       },
  --       suggestion = {
  --         accept = '<M-l>',
  --         next = '<M-]>',
  --         prev = '<M-[>',
  --         dismiss = '<C-]>',
  --       },
  --       jump = {
  --         next = ']]',
  --         prev = '[[',
  --       },
  --       submit = {
  --         normal = '<CR>',
  --         insert = '<C-s>',
  --       },
  --       sidebar = {
  --         apply_all = 'A',
  --         apply_cursor = 'a',
  --         switch_windows = '<Tab>',
  --         reverse_switch_windows = '<S-Tab>',
  --       },
  --     },
  --     hints = { enabled = true },
  --
  --     -- openai = {
  --     --
  --     --   endpoint = "https://api.openai.com/v1",
  --     --   model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
  --     --   timeout = 30000, -- timeout in milliseconds
  --     --   temperature = 0, -- adjust if needed
  --     --   max_tokens = 4096,
  --     --   reasoning_effort = "high" -- only supported for "o" models
  --     -- },
  --   },
  --   -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  --   build = 'make',
  --   -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  --   dependencies = {
  --     'stevearc/dressing.nvim',
  --     'nvim-lua/plenary.nvim',
  --     'MunifTanjim/nui.nvim',
  --     --- The below dependencies are optional,
  --     -- "echasnovski/mini.pick", -- for file_selector provider mini.pick
  --     'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
  --     'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
  --     -- "ibhagwan/fzf-lua", -- for file_selector provider fzf
  --     'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
  --     -- "zbirenbaum/copilot.lua", -- for providers='copilot'
  --     -- {
  --     --   -- support for image pasting
  --     --   "HakonHarnes/img-clip.nvim",
  --     --   event = "VeryLazy",
  --     --   opts = {
  --     --     -- recommended settings
  --     --     default = {
  --     --       embed_image_as_base64 = false,
  --     --       prompt_for_file_name = false,
  --     --       drag_and_drop = {
  --     --         insert_mode = true,
  --     --       },
  --     --       -- required for Windows users
  --     --       use_absolute_path = true,
  --     --     },
  --     --   },
  --     -- },
  --     -- {
  --     --   -- Make sure to set this up properly if you have lazy=true
  --     --   'MeanderingProgrammer/render-markdown.nvim',
  --     --   opts = {
  --     --     file_types = { "markdown", "Avante" },
  --     --   },
  --     --   ft = { "markdown", "Avante" },
  --     -- },
  --   },
  -- },
}
