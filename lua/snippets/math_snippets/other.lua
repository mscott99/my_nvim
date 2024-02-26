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
--

return function(is_math, not_math)
  return {
    s({trig = "ce", condition = is_math, wordTrig = true, snippetType = "autosnippet"}, {t("\\colonequals")}),
    s({trig = ":=", condition = is_math, wordTrig = true, snippetType = "autosnippet"}, {t("\\colonequals")}),
    s({ trig = "Bo", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("B_\\infty") }),
    s({ trig = "Rn", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{R}^n") }),
    s({ trig = "Rk", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{R}^k") }),
    s(
      { trig = "iff", condition = is_math, wordTrig = true, priority = 1100, snippetType = "autosnippet" },
      { t("\\iff") }
    ),
    s({ trig = "UU", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\bigcup") }),
    s({ trig = "Cap", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\bigcap") }),
    s({ trig = "ooo", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t("\\infty") }),
    s({ trig = "del", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\partial") }),
    s(
      { trig = "simplex", condition = is_math, wordTrig = true, snippetType = "autosnippet" },
      { t("\\Delta^{${1:n}-1}$0") }
    ),
    s({ trig = "rng", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\range") }),
    s({ trig = "inn", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\in") }),
    s({ trig = "wt", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\subseteq") }),
    s({ trig = "apx", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\approx") }),
    s({ trig = "imp", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\implies") }),
    s({ trig = "suf", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\impliedby") }),
    s({ trig = "ct", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\supseteq") }),
    s(
      { trig = "normal", condition = is_math, wordTrig = true, snippetType = "autosnippet" },
      { t("\\mathcal{N}(0, I)") }
    ),
    s({ trig = "EE", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{E}") }),
    s({ trig = "RR", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{R}") }),
    s({ trig = "any", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\forall") }),
    s({ trig = "leq", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\le") }),
    s({ trig = "geq", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\ge") }),
    s({ trig = "les", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\lesssim") }),
    s({ trig = "ges", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\gtrsim") }),
    s({ trig = [[__]], wordTrig = false, condition = is_math, snippetType = "autosnippet" }, fmta("_{<>}", { i(1) })),
    s({ trig = "^^", wordTrig = false, condition = is_math, snippetType = "autosnippet" }, fmta("^{<>}", { i(1) })),
    s(
      { trig = "ldot", wordTrig = false, prority = 1000, condition = is_math, snippetType = "autosnippet" },
      { t("\\ldots") }
    ),
    s({ trig = "dot", wordTrig = false, condition = is_math, snippetType = "autosnippet" }, { t("\\cdot") }),

    s({ trig = "sq", priority = 900, condition = is_math, snippetType = "autosnippet" }, fmta("\\sqrt{<>}", { i(1) })),
    s(
      {
        trig = [[([^ %[({\<'%$])sq]],
        regTrig = true,
        wordTrig = false,
        condition = is_math,
        snippetType = "autosnippet",
      },
      { f(function(_, snip)
        return snip.captures[1] .. "^2"
      end) }
    ),

    s(
      { trig = "([^ ])cub", regTrig = true, wordTrig = false, condition = is_math, snippetType = "autosnippet" },
      { f(function(_, snip)
        return snip.captures[1] .. "^3"
      end) }
    ), -- make another one for letters where it is a wordTrig.
    s({
      trig = "([^ %=-+_&$./^,%d{([]+)([%d])",
      regTrig = true,
      priority = 300,
      condition = is_math,
      snippetType = "autosnippet",
    }, { f(function(_, snip)
      return snip.captures[1] .. "_" .. snip.captures[2]
    end) }),
    -- s({trig = "([^ ij%d%p{([])([ijm])", regTrig=true, priority = 300, condition= is_math, snippetType="autosnippet"},
    --     {f(function(_, snip)
    --       return snip.captures[1] .. "_" .. snip.captures[2]
    --     end),}
    -- ),
    s(
      {
        trig = "([^ %d%p{([]+)([*T])",
        regTrig = true,
        priority = 300,
        condition = is_math,
        snippetType = "autosnippet",
      },
      { f(function(_, snip)
        return snip.captures[1] .. "^" .. snip.captures[2]
      end) }
    ),
    s(
      { trig = "sum", wordTrig = false, condition = is_math, snippetType = "autosnippet" },
      fmta([[\sum_{<> = <>}^<> ]], { i(1, "i"), i(2, "1"), i(3, "n") })
    ),
    s(
      { trig = "gau", wordTrig = true, name = "Gaussian distribution", condition = is_math, snippetType = "autosnippet" },
      fmta([[\mathcal{N}(0, <>)]], { i(1, "I")})
    ),
    s(
      { trig = "sphere", wordTrig = false, name = "sphere", condition = is_math, snippetType = "autosnippet" },
      fmta([[\mathbb{S}^{<>-1}]], { i(1, "n") })
    ),
  }
end
