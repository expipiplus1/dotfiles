---@type LazySpec
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      -- AstroNvim core plugin for mappings configuration
      "astronvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        -- Ctrl-A: Open CodeCompanion actions menu in normal and visual mode
        maps.n["<C-a>"] = { "<cmd>CodeCompanionActions<cr>", desc = "Code Companion Actions" }
        maps.v["<C-a>"] = { "<cmd>CodeCompanionActions<cr>", desc = "Code Companion Actions" }
        -- Leader-a: Toggle the CodeCompanion chat window
        maps.n["<Leader>a"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Code Companion Chat" }
        maps.v["<Leader>a"] = { "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Code Companion Chat" }
        -- ga: Add selected text to CodeCompanion chat (visual mode only)
        maps.v["ga"] = { "<cmd>CodeCompanionChat Add<cr>", desc = "Add to Code Companion Chat" }
      end,
    },
  },
  config = function()
    require("codecompanion").setup {
      adapters = {
        acp = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              commands = {
                default = { "claude-code-acp" },
              },
            })
          end,
        },
        claude_server = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            url = "http://localhost:8000/v1/chat/completions",
            env = {
              api_key = "not-needed",
            },
            schema = {
              model = {
                default = "claude-sonnet-4-5-20250929",
              },
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "claude_code",
        },
        inline = {
          adapter = "claude_server",
        },
      },
    }
    -- Create command abbreviation: typing 'cc' expands to 'CodeCompanion'
    vim.cmd [[cab cc CodeCompanion]]
  end,
}

