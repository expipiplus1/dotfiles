local mapsx = {
  ["s"] = { "<Plug>(leap-forward)", desc = "Leap forward" },
  ["S"] = { "<Plug>(leap-backward)", desc = "Leap backward" },
  ["gs"] = { "<Plug>(leap-from-window)", desc = "Leap from window" },
  ["ga"] = {
    function() require("leap.treesitter").select() end,
    desc = "Leap treesitter node selection",
  },
  ["gA"] = {
    'V<cmd>lua require("leap.treesitter").select()<cr>',
    desc = "Leap linewise treesitter node selection",
  },
}
local maps = require("astrocore").extend_tbl({
  ["gS"] = {
    function() require("leap.remote").action() end,
    desc = "Leap remote action",
  },
}, mapsx)

return {
  "ggandor/leap.nvim",
  dependencies = {
    "tpope/vim-repeat",
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          n = maps,
          x = mapsx,
          o = maps,
        },
      },
    },
  },
  specs = {
    {
      "catppuccin",
      optional = true,
      ---@type CatppuccinOptions
      opts = { integrations = { leap = true } },
    },
  },
  opts = {},
}
