return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    local actions = require "telescope.actions"
    return require("astrocore").extend_tbl(opts, {
      pickers = {
        live_grep = {
          mappings = {
            i = {
              ["<C-f>"] = actions.to_fuzzy_refine,
            },
          },
        },
      },
    })
  end,
}
