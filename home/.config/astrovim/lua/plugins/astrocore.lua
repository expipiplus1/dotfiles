-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 4096 * 256, lines = 30000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = false, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    autocmds = {
      disable_format_on_save_in_work_dir = {
        {
          event = { "BufNewFile", "BufRead", "BufAdd" },
          pattern = os.getenv "HOME" .. "/work/*",
          desc = "Disable format-on-save for files in ~/work directory",
          callback = function(args) vim.b[args.buf].autoformat = false end,
        },
      },
      haskell_keywords = {
        {
          event = { "FileType" },
          pattern = "haskell",
          desc = "Set iskeyword options for Haskell files",
          callback = function()
            vim.opt_local.iskeyword:append "'"
            vim.opt_local.iskeyword:remove "."
          end,
        },
      },
      hlsl_commentstring = {
        {
          event = { "FileType" },
          pattern = "hlsl",
          desc = "Set commentstring",
          callback = function() vim.opt_local.commentstring = "// %s" end,
        },
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false,
        number = false,
        spell = false,
        signcolumn = "yes",
        wrap = true,
        foldcolumn = "0",
        clipboard = "",
        laststatus = 2,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- mappings for creating splits
        ["<C-Space>v"] = { ":vsplit<CR>", desc = "Create vertical split" },
        ["<C-Space>s"] = { ":split<CR>", desc = "Create horizontal split" },

        ["<Leader>W"] = { ":wa<CR>", desc = "Write all files" },

        ["<leader>y"] = {
          function()
            vim.fn.setreg("+", vim.fn.getreg "0")
            print "copied to CTRL-C clipboard"
          end,
          desc = "Copy to CTRL-C clipboard",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      v = { ["<"] = "<gv", [">"] = ">gv" },
      i = {
        ["<C-d>"] = { "<C-k>", desc = "Enter digraph insert mode" },
      },
    },
  },
}
