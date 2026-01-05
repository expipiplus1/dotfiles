return {
  dir = vim.fn.stdpath "config" .. "/custom-plugins/fiddle_highlight",
  ft = { "cpp", "c" }, -- Lazy load on these filetypes
  config = function() require("fiddle_highlight").setup() end,
}
