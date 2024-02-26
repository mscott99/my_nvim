local unflattened = {
  require("snippets.math_snippets.frac"),
  require("snippets.math_snippets.greek"),
  require("snippets.math_snippets.hats"),
  require("snippets.math_snippets.large"),
  require("snippets.math_snippets.no_backslash"),
  require("snippets.math_snippets.other"),
  require("snippets.math_snippets.surrounds"),
}

local map = require("snippets.utils").map
local concat = require("snippets.utils").concat

local check_tex_is_math = require("snippets.utils").in_tex_mathzone

local check_tex_is_not_math = function()
  return not check_tex_is_math()
end

local function make_tex_snippet(snip_fn)
    return snip_fn(check_tex_is_math, check_tex_is_not_math)
end

return concat(map(unflattened, make_tex_snippet))
