local all_greeks = require("snippets.utils").redundant_starting_greeks
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local doubleMap = require("snippets.utils").doubleMap

local subscript_letters = {
  "i",
  "j",
  "k",
}

return function(is_math, not_math)
  local function greek_ijk_subscripts(greek, sub)
    return s({
      trig = "\\" .. greek .. sub,
      wordTrig = false,
      name = greek .. "_" .. sub,
      priority = 3000,
      condition = is_math,
      snippetType = "autosnippet",
    }, { t("\\" .. greek .. "_" .. sub .. " ")})
  end
  return doubleMap(all_greeks, subscript_letters, greek_ijk_subscripts)
end
