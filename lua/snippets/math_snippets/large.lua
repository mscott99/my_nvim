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
local get_prev_align_line = require("snippets.utils").get_prev_align_line

-- important note: snippets cannot remove newlines, it breaks treesitter inside of envs.
return function(is_math, not_math)
  return {
    s(
      { trig = "align", wordTrig = true, name = "align", condition = not_math},
      { t({"$$", "\\begin{"}), i(1, "align*"), t({"}", ""}), t("  "), i(2), t({"", "\\end{"}), rep(1), t({"}", "$$", ""})}
    ),
    s(
      { trig = "fal", wordTrig = true, name = "first align", describe = "[F]irst [Al]ign", condition = is_math, snippettype= "autosnippet"},
      { i(1, "A"), t(" &"), i(2, "="), t(" "), i(3, "B"), t(" \\\\")}
    ),
    s(
      { trig = "nal", wordTrig = true, name = "next align", describe = "[F]irst [Al]ign", condition = is_math, snippettype= "autosnippet"},
      { t(" &"), i(1, "="), t(" "), d(2, get_prev_align_line ), i(3), t("\\\\")}
    ),
    s(
      { trig = "int", wordTrig = true, name = "integral", condition = is_math },
      fmta([[\int_{<>}^{<>} <> d<>]], { i(1, "x=0"), i(2, "\\infty"), d(3, get_visual), i(4, "x") })
    ),
    s(
      { trig = "vecs", wordTrig = true, name = "vectors", condition = not_math },
      fmta([[$<>_<>, \ldots, <>_<> \in <>$]], { i(1, "a"), i(2, "1"), rep(1), i(3, "l"), i(4, "\\mathbb{R}^n") })
    ),
    s(
      { trig = "matrix", wordTrig = true, name = "matrix definition", condition = not_math },
      fmta([[$<> \in <>^{<> \times <>}$]], { i(1, "M"), i(2, "\\mathbb{R}"), i(3, "m"), i(4, "n") })
    ),
    s(
      { trig = "fni", wordTrig = true, name = "inline function definition", condition = not_math },
      fmta([[$<>:<> \to <>, <> \mapsto <>$]], { i(1, "f"), i(2, "\\mathbb{R}^n"), i(3, "\\mathbb{R}"), i(4, "x"), i(5, "x^2")})
    ),
    s(
      { trig = "fnd", wordTrig = true, name = "display function definition", condition = not_math },
      fmta([[
$$
<> \colon \biggl\{\begin{align*}
    <>  &\to <>,\\
    <> &\mapsto <>
\end{align*}
$$

]], { i(1, "f"), i(2, "\\mathbb{R}^n"), i(3, "\\mathbb{R}"), i(4, "x"), i(5, "x^2")})
    ),
    s(
      { trig = "set", wordTrig = true, name = "set def", condition = not_math },
      fmta([[$<> \subseteq <>^<>$]], { i(1, "S"), i(2, "\\mathbb{R}"), i(3, "n")})
    ),
    s(
      { trig = "comb", wordTrig = true, name = "Linear interpolation", condition = is_math },
      { i(1, "\\alpha"), t(" "), i(2, "x"), t(" + (1 - "), rep(1), t(") "), i(3, "y") }
    ),

    -- s({trig = "int", wordTrig=true, name ="integral", condition= is_math},
    --   fmta([[\int_{<>}^{<>} <> d<>]],
    --     {i(1), i(2), rep(1)})),
    --
    s(
      { trig = "beg", wordTrig = true, name = "environment", condition = is_math },
      fmta(
        [[\begin{<>
   <>
\end<>]],
        { i(1), i(2), rep(1) }
      )
    ),
  }
end
