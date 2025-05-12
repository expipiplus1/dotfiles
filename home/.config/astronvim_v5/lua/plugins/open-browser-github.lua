---@type LazySpec
return {
  "tyru/open-browser-github.vim",
  event = "VeryLazy",
  dependencies = {
    "tyru/open-browser.vim",
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        opts.mappings.n["<leader>gf"] = {
          ":OpenGithubFile<CR>",
          desc = "Open file in GitHub",
        }
        opts.mappings.v["<leader>gf"] = {
          ":OpenGithubFile<CR>",
          desc = "Open file in GitHub",
        }
      end,
    },
  },
}
