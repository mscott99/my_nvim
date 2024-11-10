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
local greek_letters = require("snippets.utils").redundant_starting_greeks
local concat = require("snippets.utils").concat
local doubleMap = require("snippets.utils").doubleMap
local map = require("snippets.utils").map
local strict_grab = require("snippets.utils").strict_grab

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
    trig = "tld",
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

local word_snippets = {
  {
    trig = "rm",
    tex = "mathrm",
  },
}

return function(is_math, not_math)
  local function make_letter_hat_snippet(hat)
    return s({
      trig = hat.trig,
      regTrig = false,
      wordTrig = false,
      --TODO: make another snippet that includes everything up to space
      name = "letter_".. hat.tex,
      priority = 150,
      condition = is_math,
      snippetType = "autosnippet",
    }, { f(function(_, snip)
        local content = strict_grab()
        return "\\" .. hat.tex .. "{" .. content .. "}"
      end) })
  end

  local function make_word_hat_snippet(hat)
    return s({
      trig = "([^$%{%}| _%[%]()]+)" .. hat.trig,
      -- trig = "(%a)" .. hat.trig,
      regTrig = true,
      wordTrig = false,
      --TODO: make another snippet that includes everything up to space
      name = hat.tex,
      priority = 100,
      condition = is_math,
      snippetType = "autosnippet",
    }, { f(function(_, snip)
      return "\\" .. hat.tex .. "{" .. snip.captures[1] .. "}"
    end) })
  end

  local function greek_hat_snippets(letter, hat)
    return s({
      trig = "\\" .. letter .. " " .. hat.trig,
      regTrig = true,
      wordTrig = false,
      name = letter .. " ".. hat.tex,
      priority = 700,
      condition = is_math,
      snippetType = "autosnippet",
    }, { f(function(_, snip)
        return "\\" .. hat.tex .. "{\\" .. letter .. "}"
      end) })
  end

  return concat({doubleMap(greek_letters, hats, greek_hat_snippets),  map(word_snippets, make_word_hat_snippet), map(hats, make_letter_hat_snippet)})
  -- ,
end
