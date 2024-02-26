local ls = require("luasnip")
local s = ls.snippet
local fmta = require("luasnip.extras.fmt").fmta
local d = ls.dynamic_node
local get_visual = require("snippets.utils").get_visual
return {
    -- s({ trig = "(", wordTrig = false, priority = 200, snippetType = "autosnippet" }, fmta([[(<>)]], { d(1, get_visual) })),
    -- s({ trig = "[", wordTrig = false, priority = 200, snippetType = "autosnippet" }, fmta("[<>]", { d(1, get_visual) })),
    -- s({ trig = "{", wordTrig = false, priority = 200, snippetType = "autosnippet" }, fmta("{<>}", { d(1, get_visual) })),
}
