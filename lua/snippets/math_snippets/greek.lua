local ls = require 'luasnip'
local f = ls.function_node
local fmta = require('luasnip.extras.fmt').fmta
local s = ls.snippet
local t = ls.text_node
local greek_letters = require('snippets.utils').greek_letters
local all_greek_letters = require('snippets.utils').redundant_starting_greeks
local short_greek = require('snippets.utils').short_greek

return function(is_math, not_math)
  local letter_snippets = vim.tbl_map(function(element)
    local first_letter = string.sub(element, 1, 1)
    -- local second_letter = string.sub(element, 2, 2)
    return s({
      name = element,
      -- trig = ";" .. first_letter .. second_letter,
      trig = ';' .. first_letter,
      wordTrig = false, -- I need these to work even after the underscore.
      condition = is_math,
      snippetType = 'autosnippet',
      priority = 300,
    }, { t('\\' .. element) })
  end, greek_letters)

  local no_bck_snippets = vim.tbl_map(function(element)
    return s({
      name = element,
      trig = element,
      wordTrig = false,
      condition = is_math,
      snippetType = 'autosnippet',
      priority = 300,
    }, { t('\\' .. element) })
  end, short_greek)
  vim.list_extend(letter_snippets, no_bck_snippets)
  local space_after = vim.tbl_map(function(element)
    return s(
      {
        trig = '(\\' .. element .. ')(%a)',
        name = 'autospace',
        dscr = 'add a space after the greek letter',
        priority = 300,
        regTrig = true,
        condition = is_math,
        snippetType = 'autosnippet',
      },
      fmta(
        [[
        <> <>
        ]],
        {
          f(function(_, snip)
            return snip.captures[1]
          end),
          f(function(_, snip)
            return snip.captures[2]
          end),
        }
      )
    )
  end, all_greek_letters)
  vim.list_extend(letter_snippets, space_after)
  vim.list_extend(letter_snippets, {
    s({
      name = 'vareps',
      trig = ';e',
      wordTrig = false,
      priority = 400,
      condition = is_math,
      snippetType = 'autosnippet',
    }, { t '\\varepsilon' }),
    s({ name = 'ell', trig = ';ll', wordTrig = false, condition = is_math, snippetType = 'autosnippet', priority = 400 }, { t '\\ell' }),
    s({ name = 'eta', trig = ';ll', wordTrig = false, condition = is_math, snippetType = 'autosnippet', priority = 400 }, { t '\\eta' }),
  })
  return letter_snippets
end
