local en = "keyboard-us"
local ja = "mozc"

---@type LazySpec
return {
  "pysan3/fcitx5.nvim",
  event = "VeryLazy",
  opts = {
    imname = {
      norm = en,
      ins = en,
      cmd = en,
    },
    remember_prior = true,
    define_autocmd = true,
  },
}
