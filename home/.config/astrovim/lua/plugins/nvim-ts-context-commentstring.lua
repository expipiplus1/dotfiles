---@type LazySpec
return {
  "JoosepAlviste/nvim-ts-context-commentstring",
  opts = function(_, opts) opts.languages.hlsl = "// %s" end,
}
