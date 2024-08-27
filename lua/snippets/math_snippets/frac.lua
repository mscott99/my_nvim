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
    s({ condition = not_math, trig = "mk", name = "Math", snippetType = "autosnippet" }, fmta([[$<>$]], { i(1) })),
    s(
      { condition = not_math, trig = "dm", name = "Math", snippetType = "autosnippet" },
      fmta("$$<>$$\n", { i(1) })
    ),
    s(
      {
        condition = is_math,
        trig = "//",
        wordtrig = true,
        name = "fraction",
        dscr = "fraction (general)",
        snippetType = "autosnippet",
      },
      fmta([[\frac{<>}{<>}]], { d(1, get_visual), i(2, "b") })
    ),
    s(
      {
        trig = "(%b())/",
        name = "fraction",
        dscr = "auto fraction 2",
        priority = 1100,
        regTrig = true,
        hidden = true,
        condition = is_math,
        snippetType = "autosnippet",
      },
      fmta(
        [[
    \frac{<>}{<>}<>
    ]],
        {
          f(function(_, snip)
            return string.sub(snip.captures[1], 2, -2)
          end),
          i(1),
          i(0),
        }
      )
    ),
    s(
      {
        trig = "([^%$%(%)%[%]{} |]+)/",
        name = "fraction",
        dscr = "auto fraction 1",
        condition = is_math,
        snippetType = "autosnippet",
        regTrig = true,
        hidden = true,
      },
      fmta(
        [[
    \frac{<>}{<>}<>
    ]],
        { f(function(_, snip)
          return snip.captures[1]
        end), i(1), i(0) }
      ),
      {
        -- condition = is_math, show_condition = is_math
      }
    ),
  }
end
