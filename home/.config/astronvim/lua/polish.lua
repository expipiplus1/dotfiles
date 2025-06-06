-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.filetype.add {
  extension = {
    slang = "slang",
    argot = "argot",
    idr = "idris2",
    idris = "idris2",
  },
  filename = {
    ["Foofile"] = "fooscript",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
  },
}

-- Not sure why this doesn't work in astrocore...
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove "o"
    -- print(vim.o.scroll)
    -- vim.o.scroll = 18
  end,
})

-- combining circumflex
vim.fn.digraph_set("^^", "\u{0302}")

-- combining tilde
vim.fn.digraph_set("^~", "\u{0303}")

-- combining rightwards arrow above
vim.fn.digraph_set("^>", "\u{20D7}")

vim.fn.digraph_set("|-", "⊩")

vim.opt.shortmess = vim.opt.shortmess + { A = true }

-- Don't be distracted by backslashes near parens
vim.opt.cpoptions = vim.opt.cpoptions + { M = true }

vim.g.haskell_tools = require("astrocore").extend_tbl({
  ---@type HaskellLspClientOpts
  hls = {
    settings = {
      haskell = {
        formattingProvider = "fourmolu",
        formatOnImportOn = true,
        plugin = {
          ["ghcide-completions"] = { config = { snippetsOn = false, autoExtendOn = true } },
          rename = { config = { crossModule = true } },
          stan = { globalOn = false },
        },
      },
    },
  },
}, vim.g.haskell_tools)

vim.on_key(nil, vim.api.nvim_get_namespaces()["auto_hlsearch"])
