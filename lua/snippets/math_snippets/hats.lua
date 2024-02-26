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

local function tableConcat(t1,t2)
    for j=1,#t2 do
        t1[#t1+1] = t2[j]
    end
    return t1
end

local hats = {
  {
    trig = "bar",
    tex = "bar",
  },
  {
    trig = "vec",
    tex = "vec",
  },
  {
    trig = "tilde",
    tex = "tilde",
  },
  {
    trig = "hat",
    tex = "hat",
  },
  {
    trig = "bm",
    tex = "bm",
  },
  {
    trig = "tt",
    tex = "text",
  },
  {
    trig = "bb",
    tex = "mathbb",
  },
  {
    trig = "rm",
    tex = "mathrm",
  },
  {
    trig = "br",
    tex = "mathbr",
  },
  {
    trig = "bs",
    tex = "boldsymbol",
  },
  {
    trig = "bf",
    tex = "mathbf",
  },
  {
    trig = "cal",
    tex = "mathcal",
  },
  {
    trig = "rb",
    tex = "mathrb",
  },
}

local map = require("snippets.utils").map

return function(is_math, not_math)
  local function make_hat_snippet(hat)
    return s({
      trig = "([^$| {}%[%]()]+)" .. hat.trig,       regTrig = true,
      --TODO: make another snippet that includes everything up to space
      name = hat.tex,
      priority = 100,
      condition = is_math,
      snippetType = "autosnippet",
    }, { f(function(_, snip)
      return "\\" .. hat.tex .. "{" .. snip.captures[1] .. "}"
    end) })
  end

  local function make_big_hat_snippet(hat)
    return s({
      trig = "([^$| ]+[%)%]%}])" .. hat.trig,
      regTrig = true,
      name = "big" .. hat.tex,
      priority = 100,
      condition = is_math,
      snippetType = "autosnippet",
    }, { f(function(_, snip)
      return "\\" .. hat.tex .. "{" .. snip.captures[1] .. "}"
    end) })
  end
  return tableConcat(map(hats, make_hat_snippet), map(hats, make_big_hat_snippet))
end

