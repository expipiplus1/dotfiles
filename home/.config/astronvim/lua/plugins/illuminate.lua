---@type LazySpec
return {
  {
    "RRethy/vim-illuminate",
    specs = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["]r"] = { function() require("illuminate")["goto_next_reference"]() end, desc = "Next reference" }
          maps.n["[r"] = { function() require("illuminate")["goto_prev_reference"]() end, desc = "Previous reference" }
          maps.n["<Leader>ur"] = {
            function() require("illuminate").toggle_visibility_buf() end,
            desc = "Toggle reference highlighting (buffer)",
          }
          maps.n["<Leader>uR"] =
            { function() require("illuminate").toggle() end, desc = "Toggle reference highlighting (global)" }
          opts.autocmds.disable_illuminate = {
            {
              event = { "BufNewFile", "BufRead", "BufAdd" },
              desc = "Turn off illuminate underlining",
              callback = function() require("illuminate").invisible_buf() end,
            },
          }
        end,
      },
    },
  },
}
