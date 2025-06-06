-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.colorscheme.nord-nvim", enabled = true },
  { import = "astrocommunity.colorscheme.kanagawa-nvim", enabled = true },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.haskell" },
  { import = "astrocommunity.pack.cpp", enabled = true },
  { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.pack.jj" },
  { import = "astrocommunity.recipes.disable-tabline" },
  { import = "astrocommunity.editing-support.vim-visual-multi" },
  { import = "astrocommunity.editing-support.treesj" },
  { import = "astrocommunity.editing-support.nvim-treesitter-context" },
  { import = "astrocommunity.motion/nvim-surround" },
  -- { import = "astrocommunity.workflow/hardtime-nvim" }, -- It's too hard lol
  { import = "astrocommunity.markdown-and-latex/render-markdown-nvim" },
}
