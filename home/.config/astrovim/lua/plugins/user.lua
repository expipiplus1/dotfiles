-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function() require("lsp_signature").setup() end,
  -- },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    dependencies = { "echasnovski/mini.icons" },
    config = function() require("alpha").setup(require("alpha.themes.startify").config) end,
  },
  {
    "beyondmarc/hlsl.vim",
  },
  {
    "hrsh7th/cmp-buffer",
  },
  {
    "tpope/vim-abolish",
  },
  {
    "sustech-data/wildfire.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function() require("wildfire").setup() end,
  },
  {
    "max397574/better-escape.nvim",
    enabled = false,
  },
  {
    "kylechui/nvim-surround",
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          opts.mappings.n["<C-g>z"] = "<Plug>(nvim-surround-insert)"
          opts.mappings.n["gC-ggZ"] = "<Plug>(nvim-surround-insert-line)"
          opts.mappings.n["gz"] = "<Plug>(nvim-surround-normal)"
          opts.mappings.n["gZ"] = "<Plug>(nvim-surround-normal-cur)"
          opts.mappings.n["gzz"] = "<Plug>(nvim-surround-normal-line)"
          opts.mappings.n["gZZ"] = "<Plug>(nvim-surround-normal-cur-line)"
          opts.mappings.n["gz"] = "<Plug>(nvim-surround-visual)"
          opts.mappings.n["gZ"] = "<Plug>(nvim-surround-visual-line)"
          opts.mappings.n["dz"] = "<Plug>(nvim-surround-delete)"
          opts.mappings.n["cz"] = "<Plug>(nvim-surround-change)"
        end,
      },
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    opts = function(_, opts)
      return require("astrocore").extend_tbl({
        element_mappings = {
          stacks = {
            open = { "o", "<CR>", "<2-LeftMouse>" },
          },
        },
      }, opts)
    end,
  },
  {
    "lucaSartore/nvim-dap-exception-breakpoints",
    dependencies = { "mfussenegger/nvim-dap" },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          opts.mappings.n["<leader>de"] =
            { desc = "[D]ebug [E]xception breakpoints", callback = require "nvim-dap-exception-breakpoints" }
        end,
      },
    },
  },
  { "dhruvasagar/vim-table-mode" },

  -- -- You can disable default plugins as follows:
  -- { "max397574/better-escape.nvim", enabled = false },
  --
  -- -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  -- {
  --   "L3MON4D3/LuaSnip",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom luasnip configuration such as filetype extend or custom snippets
  --     local luasnip = require "luasnip"
  --     luasnip.filetype_extend("javascript", { "javascriptreact" })
  --   end,
  -- },
  --
  -- {
  --   "windwp/nvim-autopairs",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom autopairs configuration such as custom rules
  --     local npairs = require "nvim-autopairs"
  --     local Rule = require "nvim-autopairs.rule"
  --     local cond = require "nvim-autopairs.conds"
  --     npairs.add_rules(
  --       {
  --         Rule("$", "$", { "tex", "latex" })
  --           -- don't add a pair if the next character is %
  --           :with_pair(cond.not_after_regex "%%")
  --           -- don't add a pair if  the previous character is xxx
  --           :with_pair(
  --             cond.not_before_regex("xxx", 3)
  --           )
  --           -- don't move right when repeat character
  --           :with_move(cond.none())
  --           -- don't delete if the next character is xx
  --           :with_del(cond.not_after_regex "xx")
  --           -- disable adding a newline when you press <cr>
  --           :with_cr(cond.none()),
  --       },
  --       -- disable for .vim files, but it work for another filetypes
  --       Rule("a", "a", "-vim")
  --     )
  --   end,
  -- },
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      table.insert(opts.servers, "argot")
      opts.config = require("astrocore").extend_tbl(opts.config or {}, {
        argot = {
          cmd = { "argotd-interpreted" },
          filetypes = { "argot" },
          root_dir = require("lspconfig.util").root_pattern(".jj", ".git"),
        },
      })
    end,
  },
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      table.insert(opts.servers, "idris2")
      opts.config = require("astrocore").extend_tbl(opts.config or {}, {
        idris2 = {
          cmd = { "idris2-lsp" },
          filetypes = { "idris2" },
          root_dir = require("lspconfig.util").root_pattern(".jj", ".git"),
        },
      })
    end,
  },
  -- {
  --   "neovim/nvim-lspconfig",
  --   setup = function()
  --     local lspconfig = require "lspconfig"
  --     lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
  --       handlers = {
  --         ["window/showMessage"] = function(err, method, params, client_id)
  --           require("astrocore").notify(params.message)
  --           vim.lsp.handlers["window/showMessage"](err, method, params, client_id)
  --         end,
  --       },
  --     })
  --   end,
  -- },
}
