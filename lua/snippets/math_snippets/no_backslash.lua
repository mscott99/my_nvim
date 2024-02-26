-- -- Abbreviations used in this article and the LuaSnip docs
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local no_backslash = {
  "times",
  "cos",
  "sin",
  "arcsin",
  "arccos",
  "prob",
  "sec",
  "cosec",
  "tan",
  "atan",
  "asin",
  "acos",
  "cotan",
  "conv",
  "log",
  "quad",
  "qquad",
  "min",
  "max",
  "argmin",
  "argmax",
  "proj",
  "dist",
  "odot",
  "cdot",
  "to",
  "ll",
  "ln",
  "star",
  "perp",
  "field",
  "exp",
  "cot",
  "exists",
  "not",
  "iff",
  "implies",
  "neq",
  "sim",
  "inf",
  "sup",
  "limsup",
  "liminf",
  "circ",
  "cap",
  "cup",
  "Cap",
  "Cup",
}

local map = require("snippets.utils").map

return function(is_math, not_math)
  local function prefix_backslash(name)
    return s(
      { condition = is_math, trig = name, name = "fraction", dscr = "fraction (general)", snippetType = "autosnippet" },
      { t("\\" .. name) }
    )
  end

  return map(no_backslash, prefix_backslash)
end
