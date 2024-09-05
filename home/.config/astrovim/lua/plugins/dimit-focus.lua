return {
  dir = vim.fn.stdpath "config" .. "/custom-plugins/dimit-focus",
  opts = {
    bgcolor = "#2A2A37",
    dim_elements = {
      "ColorColumn",
      "CursorColumn",
      "CursorLine",
      "CursorLineFold",
      "CursorLineNr",
      "CursorLineSign",
      "EndOfBuffer",
      "FoldColumn",
      "LineNr",
      "NonText",
      "Normal",
      "SignColumn",
      -- "VertSplit",
      "Whitespace",
      -- "WinBarNC",
      -- "WinSeparator",
    },
  },
}
