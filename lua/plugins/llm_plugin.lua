return {
  {
    'gsuuon/model.nvim',
    cmd = { 'M', 'Model', 'Mchat' },
    init = function()
      vim.filetype.add { extension = { mchat = 'mchat' } }
    end,
    ft = 'mchat',
    keys = {
      -- { '<C-m>d', ':Mdelete<cr>', mode = 'n' },
      -- { '<C-m>s', ':Mselect<cr>', mode = 'n' },
      -- { '<C-Enter>', ':Mchat<cr>', mode = 'n' },
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
      local sse = require 'model.util.sse'
      local util = require 'model.util'
      local gemini_provider = require 'model.providers.gemini'

      ---@class Provider
      local grok_provider = {
        request_completion = function(handler, params, options)
          options = options or {}
          local consume = handler.on_partial
          local finish = function() end
          if options.trim_code then
            -- we keep 1 partial in buffer so we can strip the leading newline and trailing markdown block fence
            local last = nil
            ---@param partial string
            consume = function(partial)
              if last then
                handler.on_partial(last)
                last = partial
              else -- strip the first leading newline
                last = partial:gsub('^\n', '')
              end
            end
            finish = function()
              if last then
                -- ignore the trailing codefence
                handler.on_partial(last:gsub('\n```$', ''))
              end
            end
          end
          return sse.curl_client({
            url = 'https://api.x.ai/v1/chat/completions',
            headers = vim.tbl_extend('force', {
              ['Content-Type'] = 'application/json',
              ['Authorization'] = 'Bearer ' .. util.env 'XAI_API_KEY',
            }, options.headers or {}),
            body = vim.tbl_deep_extend('force', {
              max_tokens = 1024, -- required field
            }, params, { stream = true }),
          }, {
            on_message = function(msg)
              if msg.data == '[DONE]' then
                finish()
                return
              end
              local data = util.json.decode(msg.data)
              if data == nil then
                finish()
              end
              if data and #data.choices ~= 0 and data.choices[1].delta ~= nil and data.choices[1].delta.content ~= nil then
                consume(data.choices[1].delta.content)
              end
              if data and #data.choices ~= 0 and data.choices[1].finish_reason == 'stop' then
                finish()
              end
            end,
            on_error = handler.on_error,
            on_other = handler.on_error,
            on_exit = handler.on_finish,
          })
        end,
      }

      require('model').setup {
        chats = {
          claude_chat = {
            provider = claude,
            system = 'You are a helpful assistant for note-taking and prose editing. When referring to files notes in my Obsidian vault (~/Obsidian/myVault/), do it with wikilinks [[...]] with the name of the file as the address, without the ".md", and without the directories in which they are. Put headers for specific sections, and line numbers (the line numbers should not be inside the wikilink).',
            create = function()
              return ''
            end,
            run = function(messages, config)
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
          claude_code = {
            provider = claude,
            system = 'You are an expert programmer who knows about Obsidian. You are good a building Obsidian plugins and doing data science with python.',
            create = function()
              return ''
            end,
            run = function(messages, config)
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
            provider = grok_provider,
            system = 'You are a helpful assistant, expert in programming lua in neovim, python with dataframes and seaborn and mathematical ideas in optimization and compressed sensing. Math is discovered. You like clarity in the math, but you also value saying things that dive to the core truth of the concepts, not being overly reliant on the specific way they are formalized. You are CONCISE. Every word you use is expensive, choose what you say judiciously. Tell the truth. Your answers hold a single idea, or a single step.',
            create = function()
              return ''
            end,
            run = function(messages, config)
              -- Format for OpenAI-compatible API: system in messages
              local full_messages = { { role = 'system', content = config.system } }
              vim.list_extend(full_messages, messages)
              return {
                messages = full_messages,
                model = 'grok-4',
                max_tokens = 300,
                temperature = 0.7,
                top_p = 0.95,
              }
            end,
          },
        },
        prompts = {
          commit = require('model.prompts.starters').commit,
          minor_prose = {
            provider = grok_provider,
            mode = mode.INSERT_OR_REPLACE,
            options = {
              trim_code = true,
            },
            params = {
              max_tokens = 8192,
              model = 'grok-4',
              temperature = 0.5,
              top_p = 0.95,
            },
            builder = function(input, context)
              local system =
                'You are an academic writer and an applied mathematician. You know english grammar very well. You only use fancy words if their meaning is accurate and helpful, and you match the style of the surrounding text. Each change should be discrete and easily understandable from a line-wise diff. Do not modify the newlines from the original. Seek truth, stay honest, make something beautiful. Feel free to make larger changes if they constitute real improvements. You usually write in markdown. When you do, write all math in latex surrounded by $...$ for inline and $$...$$ for display math. You can use the align environment in display math. Do not add extra newlines or blank lines unless absolutely necessary for clarity or structure. Preserve the original line breaks and avoid introducing additional ones. Respond only with the improved text. Do not use markdown code blocks, backticks, or any additional text.'
              local user_content = 'Improve the following text:\n' .. input
              if not context.selection then
                user_content = input -- For insert, use args/buffer as is
              end
              local messages = {
                { role = 'system', content = system },
                { role = 'user', content = user_content },
              }
              return {
                messages = messages,
                model = 'grok-4',
                max_tokens = 8192,
                temperature = 0.5,
                top_p = 0.95,
              }
            end,
          },
          qf_prose = {
            provider = grok_provider,
            mode = mode.INSERT_OR_REPLACE,
            options = {
              trim_code = true,
            },
            params = {
              max_tokens = 8192,
              model = 'grok-4',
              temperature = 0.5,
              top_p = 0.95,
            },
            builder = function(input, context)
              local system =
                'You are an academic writer and an applied mathematician. You know english grammar very well. You only use fancy words if their meaning is accurate and helpful, and you match the style of the surrounding text. Each change should be discrete and easily understandable from a line-wise diff. Do not modify the newlines from the original. Seek truth, stay honest, make something beautiful. Feel free to make larger changes if they constitute real improvements. You usually write in markdown. When you do, write all math in latex surrounded by $...$ for inline and $$...$$ for display math. You can use the align environment in display math. Do not add extra newlines or blank lines unless absolutely necessary for clarity or structure. Preserve the original line breaks and avoid introducing additional ones. Respond only with the improved text. Do not use markdown code blocks, backticks, or any additional text.'
              local qf_context = require('model.util.qflist').get_text() or ''
              local user_content = ''
              if qf_context ~= '' then
                user_content = user_content .. 'Here is relevant context from other files:\n' .. qf_context .. '\n\n'
              end
              user_content = user_content .. 'Improve the following text:\n' .. input
              if not context.selection then
                user_content = user_content .. '\n' .. (context.args or '')
              end
              local messages = {
                { role = 'system', content = system },
                { role = 'user', content = user_content },
              }
              return {
                messages = messages,
                model = 'grok-4',
                max_tokens = 8192,
                temperature = 0.5,
                top_p = 0.95,
              }
            end,
          },
          code_context = {
            provider = grok_provider,
            mode = mode.INSERT_OR_REPLACE,
            options = {
              trim_code = true,
            },
            params = {
              max_tokens = 8192,
              model = 'grok-4',
              temperature = 0.7,
              top_p = 0.95,
            },
            builder = function(input, context)
              local qf_context = require('model.util.qflist').get_text() or ''
              local system = [[
You are a reliable and tasteful coding tool that re-writes blocks of code very well. As a tool, you are only able to write code in a coding language. You never use backtick characters (`). Therefore, you cannot write code block quotes or excessive comments. You know python, typescript and Lua (for neovim) in detail. In Python, you tend to build experiments by putting them as rows of a dataframe and prioritize plotting with Seaborn from dataframes. In Lua, you are great at making simple Neovim configs. In typescript, you are an expert in making plugins for Obsidian, the markdown editor. You do not add any additional features beyond what is required, unless it is error checking. You keep comments minimal and use very few blank lines. If you think you need more context, say so inside comments in the code you return. If you realize the user is expecting a different methodology than the optimal one, proceed with the optimal version and explain why in the code comments.

Only output code and nothing but code. Every character you write is piped to a file; any additional content will create errors and frustrate the user. If you must say something, say it in comments in the proper language.
]]
              local user_prompt = ''
              if qf_context ~= '' then
                user_prompt = user_prompt .. 'Here is relevant context from other files:\n' .. qf_context .. '\n\n'
              end
              user_prompt = user_prompt .. (input or '') .. '\n\n'
              local messages = {
                { role = 'system', content = system },
                { role = 'user', content = user_prompt },
              }
              return {
                messages = messages,
                model = 'grok-4',
                max_tokens = 8192,
                temperature = 0.7,
                top_p = 0.95,
              }
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
              model = 'claude-3-5-sonnet-20240620',
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
            provider = grok_provider,
            mode = 'replace', -- Replaces selection or buffer
            builder = function(input, context)
              local system =
                'You are a great coder, improving code in a straightforward way. Provide only the modified code, the rest of your comments will be discarded. Do not wrap in code blocks or use backticks.'
              local user_content = 'Suggest an improved version of this code:\n' .. input
              return {
                messages = {
                  { role = 'system', content = system },
                  { role = 'user', content = user_content },
                },
                model = 'grok-4',
                max_tokens = 8192,
                temperature = 0.5,
                top_p = 0.95,
              }
            end,
            transform = function(response) -- Optional: Extract code if needed, but assume raw
              return response
            end,
          },
        },
      }
    end,
  },
}
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
