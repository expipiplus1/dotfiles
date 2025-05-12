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
  {
    "mrcjkb/neotest-haskell",
    enabled = false,
  },
  {
    "AstroNvim/astrolsp",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      table.insert(opts.servers, "argot")
      table.insert(opts.servers, "slang")
      opts.config = require("astrocore").extend_tbl(opts.config or {}, {
        argot = {
          cmd = { "argotd-interpreted" },
          filetypes = { "argot" },
          root_dir = require("lspconfig.util").root_pattern(".jj", ".git"),
        },
        slang = {
          cmd = { "slangd" },
          filetypes = { "slang" },
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
}
