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
local greek_letters = require("snippets.utils").greek_letters
local concat = require("snippets.utils").concat
local map = require("snippets.utils").map
local doubleMap = require("snippets.utils").doubleMap
local all_greeks = require("snippets.utils").redundant_starting_greeks

return function(is_math, not_math)
    local manual = {
    -- s({trig = "ce", condition = is_math, wordTrig = true, snippetType = "autosnippet"}, {t("\\colonequals")}),
    -- s({trig = ":=", condition = is_math, wordTrig = true, snippetType = "autosnippet"}, {t("\\colonequals")}),
    s({ trig = "\\\\\\", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t("\\setminus ") }),
    s({ trig = "par", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t("\\parallel ") }),
    s({ trig = "prop", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t("\\propto ") }),
    s({ trig = "||", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t("\\mid ") }),
    s({ trig = "ic", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\boxplus") }),
    s({ trig = "es", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\emptyset") }),
    s({ trig = "ri", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\rint") }),
    s({ trig = "cl", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\closure") }),
    s({ trig = "ems", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\emptyset") }),
    s({ trig = "mf", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\measfield") }),
    s({ trig = "om", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\ominus") }),
    s({ trig = "Bo", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("B_\\infty") }),
    s({ trig = "Rn", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{R}^n") }),
    s({ trig = "Rk", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{R}^k") }),
    s({ trig = "NN", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{N}") }),
    s({ trig = "CC", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{C}") }),
    s({ trig = "UU", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\bigcup") }),
    s({ trig = "Cap", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\bigcap") }),
    s({ trig = "ind", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\indicator") }),
    s({ trig = "alo", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\allone") }),
    s({ trig = "ooo", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t("\\infty") }),
    s({ trig = "del", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\partial") }),
    s(
      { trig = "simplex", condition = is_math, wordTrig = true, snippetType = "autosnippet" },
      { t("\\Delta^{${1:n}-1}$0") }
    ),
    s({ trig = "rng", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\range") }),
    s({ trig = "span", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\Span") }),
    s({ trig = "idp", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\indep ")}),
    s({ trig = "its", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t(" \\bar{\\cap} ") }),
    s({ trig = "inn", priority = 2000, condition = is_math, wordTrig=true, snippetType = "autosnippet" }, { t("\\in ") }),
    s({ trig = "inn", condition = is_math, wordTrig=false, snippetType = "autosnippet" }, { t(" \\in ") }),
    s({ trig = "wt", condition = is_math, wordTrig = true, priority=2000, snippetType = "autosnippet" }, { t("\\subseteq ") }),
    s({ trig = "wt", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\subseteq ") }),
    s({ trig = "wnt", condition = is_math, wordTrig = true, priority=2000, snippetType = "autosnippet" }, { t("\\subsetneq ") }),
    s({ trig = "wnt", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\subsetneq ") }),
    s({ trig = "apx", priority = 2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\approx ") }),
    s({ trig = "apx", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\approx ") }),
    s({ trig = "imp", priority=2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\implies ") }),
    s({ trig = "imp", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\implies ") }),
    s({ trig = "suf", priority=2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\impliedby ") }),
    s({ trig = "suf", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\impliedby ") }),
    s({ trig = "ct", priority=2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\supseteq ") }),
    s({ trig = "ct", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\supseteq ") }),
    s(
      { trig = "norl", condition = is_math, wordTrig = true, snippetType = "autosnippet" },
      { t("\\mathcal{N}(0, I)") }
    ),
    s({ trig = "EE", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{E}") }),
    s({ trig = "RR", condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\mathbb{R}") }),
    s({ trig = "any", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t("\\forall ") }),
    s({ trig = "leq", priority=2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\le ") }),
    s({ trig = "leq", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\le ") }),
    s({ trig = "geq", priority=2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\ge ") }),
    s({ trig = "geq", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\ge ") }),
    s({ trig = "les", priority=2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\lesssim ") }),
    s({ trig = "les", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\lesssim ") }),
    s({ trig = "ldot", priority=2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\ldots ") }),
    s({ trig = "ldot", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\ldots ") }),
    s({ trig = "=", priority=2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("= ") }),
    s({ trig = "=", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" = ") }),
    s({ trig = ",", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(", ") }),
    s({ trig = "gts", priority=2000, condition = is_math, wordTrig = true, snippetType = "autosnippet" }, { t("\\gtrsim ") }),
    s({ trig = "gts", condition = is_math, wordTrig = false, snippetType = "autosnippet" }, { t(" \\gtrsim ") }),
    s({ trig = [[__]], wordTrig = false, condition = is_math, snippetType = "autosnippet" }, fmta("_{<>}", { i(1) })),
    s({ trig = "^^", wordTrig = false, condition = is_math, snippetType = "autosnippet" }, fmta("^{<>}", { i(1) })),
    s({ trig = "rs", wordTrig = false, condition = is_math, snippetType = "autosnippet" }, fmta("^{<>}", { i(1) })),
    s({ trig = "dot", priority=2000, wordTrig = false, condition = is_math, snippetType = "autosnippet" }, { t("\\cdot ") }),

    s({ trig = "dot", wordTrig = false, condition = is_math, snippetType = "autosnippet" }, { t(" \\cdot ") }),

    s({ trig = "sq", priority = 900, condition = is_math, snippetType = "autosnippet" }, fmta("\\sqrt{<>}", { i(1) })),
    s(
      {
        trig = [[([^ %[({\<'%$])sr]],
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
      {
        trig = [[([^ %[({\<'%$])dag]],
        regTrig = true,
        wordTrig = false,
        condition = is_math,
        snippetType = "autosnippet",
      },
      { f(function(_, snip)
        return snip.captures[1] .. "^\\dagger "
      end) }
    ),
    s(
      { trig = "([^ ])invs", regTrig = true, wordTrig = false, condition = is_math, snippetType = "autosnippet" },
      { f(function(_, snip)
        return snip.captures[1] .. "^{-1}"
      end) }
    ), -- make another one for letters where it is a wordTrig.
    s(
      { trig = "([^ ])sr", regTrig = true, wordTrig = false, condition = is_math, snippetType = "autosnippet" },
      { f(function(_, snip)
        return snip.captures[1] .. "^2"
      end) }
    ), -- make another one for letters where it is a wordTrig.
    s(
      { trig = "([^ ])cub", regTrig = true, wordTrig = false, condition = is_math, snippetType = "autosnippet" },
      { f(function(_, snip)
        return snip.captures[1] .. "^3"
      end) }
    ), -- make another one for letters where it is a wordTrig.
    -- The below triggers too much.
    -- s({
    --   trig = "([^ %=-+_&$./^,%d{([]+)([%d])",
    --   regTrig = true,
    --   priority = 300,
    --   condition = is_math,
    --   snippetType = "autosnippet",
    -- }, { f(function(_, snip)
    --   return snip.captures[1] .. "_" .. snip.captures[2]
    -- end) }),
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
      fmta([[\sphere{<>}]], { i(1, "n") })
    ),
  }

  -- return manual

  local posts = {
    {trig = "sr", val = "^2"},
    {trig = "cub", val = "^3"},
    {trig = "invs", val = "^{-1}"},
  }

  local function greek_post(letter, post)
      return s({ trig = "\\" .. letter .. " " .. post.trig,
        regTrig = true, condition = is_math, snippetType = "autosnippet" }, { t("\\" .. letter .. post.val) })
  end

  local post_snips = doubleMap(all_greeks , posts, greek_post)

  local raise_trigs = map(greek_letters, function(letter)
    return s({ trig = "\\" .. letter .. " " .. "rs", priority = 1001, regTrig = true, condition = is_math, snippetType = "autosnippet" }, { t("\\" .. letter .. "^{"), i(1), t("}") })
  end)

  return concat({manual, post_snips, raise_trigs})
end
