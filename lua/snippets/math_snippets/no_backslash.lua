-- -- Abbreviations used in this article and the LuaSnip docs
local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local rep = require('luasnip.extras').rep

local no_backslash = {
  'psi',
  'phi',
  'eta',
  'ker',
  'cos',
  'sin',
  'arcsin',
  'arccos',
  'prob',
  'sec',
  'cosec',
  'tan',
  'atan',
  'asin',
  'acos',
  'cotan',
  'conv',
  'min',
  'max',
  'argmin',
  'argmax',
  'proj',
  'dist',
  'odot',
  'ln',
  'star',
  'field',
  'exp',
  'cot',
  'exists',
  'not',
  'inf',
  'sup',
  'perp',
  'limsup',
  'liminf',
  'Cap',
  'Cup',
  'circ',
  'ell',
}

local backslash_functions = {
  'diag',
  'aff',
  'span',
  'cone',
}

local no_backslash_add_space = {
  'to',
  'cap',
  'cup',
  'll',
  'implies',
  'times',
  'quad',
  'qquad',
  'neq',
  'sim',
  'iff',
  'cdot',
}

local map = require('snippets.utils').map
local concat = require('snippets.utils').concat

return function(is_math, not_math)
  local function function_backslash(name)
    return s({ trig = name, wordTrig = true, condition = is_math, snippetType = 'autosnippet' }, { t('\\' .. name .. '('), i(1), t ')' })
  end

  local function prefix_backslash(name)
    return s({ trig = name, wordTrig = false, condition = is_math, snippetType = 'autosnippet' }, { t('\\' .. name) })
  end

  local function prefix_backslash_and_space(name)
    return s({ trig = name, wordTrig = false, condition = is_math, snippetType = 'autosnippet' }, { t(' \\' .. name .. ' ') })
  end

  return concat {
    map(backslash_functions, function_backslash),
    map(no_backslash_add_space, prefix_backslash_and_space),
    map(no_backslash, prefix_backslash),
  }
end
