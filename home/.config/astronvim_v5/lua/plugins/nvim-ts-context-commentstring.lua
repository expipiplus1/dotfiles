---@type LazySpec
return {
  "JoosepAlviste/nvim-ts-context-commentstring",
  enabled = false,
  opts = function(_, opts)
    opts.enable = true
    opts.languages = {}
    opts.languages.hlsl = "// %s"
  end,
}
