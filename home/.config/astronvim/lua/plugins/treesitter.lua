-- Treesitter configuration in v6: configuration moves to AstroCore. The
-- nvim-treesitter plugin itself only acts as a parser download utility and
-- registry. Parsers are provided via Nix at $XDG_DATA_HOME/astronvim/site/parser
-- so we leave auto_install off.

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      highlight = true,
      indent = true,
      auto_install = false,
    },
  },
}
