---@type LazySpec
return {
  "julienvincent/hunk.nvim",
  dependencies = {
    "echasnovski/mini.icons",
  },
  opts = {
    keys = {
      tree = {
        toggle_file = { "a", "A" },
      },
    },
  },
}
