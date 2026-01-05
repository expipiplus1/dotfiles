---@type LazySpec
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "astronvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        maps.n["<C-a>"] = { "<cmd>CodeCompanionActions<cr>", desc = "Code Companion Actions" }
        maps.v["<C-a>"] = { "<cmd>CodeCompanionActions<cr>", desc = "Code Companion Actions" }
        maps.n["<Leader>a"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Code Companion Chat" }
        maps.v["<Leader>a"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Code Companion Chat" }
        maps.v["ga"] = { "<cmd>CodeCompanionChat Add<cr>", desc = "Add to Code Companion Chat" }
      end,
    },
  },
  config = function()
    require("codecompanion").setup {
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = {
              model = {
                default = "deepseek-coder-v2",
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "ollama",
        },
        inline = {
          adapter = "ollama",
        },
      },
    }
    vim.cmd [[cab cc CodeCompanion]]
  end,
}
