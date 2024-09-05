---@type LazySpec
return {
  "vim-visual-multi",
  dependencies = {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = assert(opts.mappings)
      maps.n["<C-c>"] = { ":call vm#commands#add_cursor_down(0, v:count1)<cr>", desc = "Add cursor below" }
    end,
  },
}
