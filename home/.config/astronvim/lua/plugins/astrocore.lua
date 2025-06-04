-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = {
        enabled = function(bufnr)
          -- Set high thresholds (adjust these values as needed)
          local size_threshold = 50000000 -- 50MB in bytes
          local line_threshold = 500000 -- 500K lines

          -- Get buffer stats
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          local file_size = ok and stats and stats.size or 0
          local line_count = vim.api.nvim_buf_line_count(bufnr)

          -- Return true (treat as large file) only if exceeds thresholds
          return file_size > size_threshold or line_count > line_threshold
        end,
      },
      autopairs = false, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    autocmds = {
      disable_format_on_save_in_src_dir = {
        {
          event = { "BufNewFile", "BufRead", "BufAdd" },
          pattern = os.getenv "HOME" .. "/src/*",
          desc = "Disable format-on-save for files in ~/src directory",
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
      idris_commentstring = {
        {
          event = { "FileType" },
          pattern = "idris",
          desc = "Set commentstring",
          callback = function() vim.opt_local.commentstring = "-- %s" end,
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
      argot_commentstring = {
        {
          event = { "FileType" },
          pattern = "argot",
          desc = "Set commentstring",
          callback = function() vim.opt_local.commentstring = "// %s" end,
        },
      },
      slang_commentstring = {
        {
          event = { "FileType" },
          pattern = "slang",
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
        scrolloff = 10,
        wildignorecase = true,
        wildmenu = true,
        wildmode = "longest:full,full",
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        clipboard = {
          name = "OSC 52",
          copy = {
            ["+"] = require("vim.ui.clipboard.osc52").copy "+",
            ["*"] = require("vim.ui.clipboard.osc52").copy "*",
          },
          paste = {
            ["+"] = require("vim.ui.clipboard.osc52").paste "+",
            ["*"] = require("vim.ui.clipboard.osc52").paste "*",
          },
        },
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
