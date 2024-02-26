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

local get_visual = require("snippets.utils").get_visual

return function(is_math, not_math)
  return {
    s({ condition = is_math, trig = "norm", snippetType = "autosnippet" }, fmta([[\|<>\|]], { d(1, get_visual) })),
    s({ condition = is_math, trig = "lrnorm", snippetType = "autosnippet" }, fmta([[\left\|<>\right\|]], { d(1, get_visual) })),
    s({ condition = is_math, trig = "set", snippetType = "autosnippet" }, fmta([[\{<>\}]], { d(1, get_visual) })),
    s({ condition = is_math, trig = "lrset", snippetType = "autosnippet" }, fmta([[\left\{<>\right\}]], { d(1, get_visual) })),
    -- s({ trig = "(", wordTrig = false, priority = 200, snippetType = "autosnippet" }, fmta([[(<>)]], { d(1, get_visual) })),
    s({ condition = is_math, trig = "lrabs", snippetType = "autosnippet" }, fmta([[\left|<>\right|]], { d(1, get_visual) })),
    s({ condition = is_math, trig = "lr|", snippetType = "autosnippet" }, fmta([[\left|<>\right|]], { d(1, get_visual) })),
    s({ condition = is_math, trig = "abs", snippetType = "autosnippet" }, fmta([[|<>|]], { d(1, get_visual) })),
    s({ condition = is_math, trig = "lr(", snippetType = "autosnippet" }, fmta([[\left(<>\right)]], { d(1, get_visual) })),
    s({ condition = is_math, trig = "lr[", snippetType = "autosnippet" }, fmta("\\left[<>\\right]", { d(1, get_visual) })),
    -- s({ trig = "[", wordTrig = false, priority = 200, snippetType = "autosnippet" }, fmta("[<>]", { d(1, get_visual) })),
    -- s({ trig = "{", wordTrig = false, priority = 200, snippetType = "autosnippet" }, fmta("{<>}", { d(1, get_visual) })),
    s(
      { condition = is_math, trig = "bra", snippetType = "autosnippet" },
      fmta("\\langle <>, <>\\rangle", { d(1, get_visual), i(2) })
    ),
    s(
      { condition = is_math, trig = "lrbra", snippetType = "autosnippet" },
      fmta("\\left\\langle <>, <>\\right\\rangle", { d(1, get_visual), i(2) })
    ),
    s({ trig = "tt", condition = is_math, snippetType = "autosnippet" }, fmta("\\text{<>}", { d(1, get_visual) })),
    s(
      { trig = "mbb", priority = 1100, condition = is_math, snippetType = "autosnippet" },
      fmta("\\mathbb{<>}", { d(1, get_visual) })
    ),
    s(
      { trig = "mbr", priority = 1100, condition = is_math, snippetType = "autosnippet" },
      fmta("\\mathbr{<>}", { d(1, get_visual) })
    ),
    s(
      { trig = "mcal", priority = 1100, condition = is_math, snippetType = "autosnippet" },
      fmta("\\mathcal{<>}", { d(1, get_visual) })
    ),
  }
end
