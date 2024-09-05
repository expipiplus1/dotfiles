-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.colorscheme.nord-nvim",           enabled = true },
  { import = "astrocommunity.colorscheme.kanagawa-nvim",       enabled = true },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.haskell" },
  { import = "astrocommunity.pack.cpp",                        enabled = true },
  { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.recipes.disable-tabline" },
  { import = "astrocommunity.editing-support.vim-visual-multi" },
  { import = "astrocommunity.editing-support.treesj" },
}
