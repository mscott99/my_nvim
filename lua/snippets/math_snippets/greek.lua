local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local greek_letters = {
  "nabla",
  "Nabla",
  "alpha",
  "Alpha",
  "beta",
  "Beta",
  "chi",
  "Chi",
  "delta",
  "Delta",
  "psi",
  "Psi",
  "xi",
  "Xi",
  "Epsilon",
  "gamma",
  "Gamma",
  "iota",
  "Iota",
  "kappa",
  "Kappa",
  "lambda",
  "Lambda",
  "mu",
  "Mu",
  "nu",
  "Nu",
  "omega",
  "Omega",
  "phi",
  "Phi",
  "pi",
  "Pi",
  "rho",
  "Rho",
  "sigma",
  "Sigma",
  "tau",
  "Tau",
  "theta",
  "Theta",
  "zeta",
  "Zeta",
  "eta",
  "Eta",
}

return function(is_math, not_math)
  local letter_snippets = vim.tbl_map(function(element)
    local first_letter = string.sub(element, 1, 1)
    local second_letter = string.sub(element, 2, 2)
    return s({
      name = element,
      trig = ";" .. first_letter .. second_letter,
      wordTrig = false, -- I need these to work even after the underscore.
      condition = is_math,
      snippetType = "autosnippet",
      priority = 300,
    }, { t("\\" .. element) })
  end, greek_letters)

  vim.list_extend(letter_snippets, {
    s(
      {
        name = "vareps",
        trig = ";ep",
        wordTrig = false,
        priority = 400,
        condition = is_math,
        snippetType = "autosnippet",
      },
      { t("\\varepsilon") }
    ),
    s(
      { name = "ell", trig = ";ll", wordTrig = false, condition = is_math, snippetType = "autosnippet", priority = 400 },
      { t("\\ell") }
    ),
  })
  return letter_snippets
end
