local function selection_count()
  local mode = vim.fn.mode(1)
  if mode:find "[vV\22]" then
    local lines = math.abs(vim.fn.line "v" - vim.fn.line ".") + 1
    return string.format(" %d lines", lines)
  end
  return ""
end

---@type LazySpec
return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    opts.statusline = {
      hl = { fg = "fg", bg = "bg" },
      status.component.git_branch(),
      status.component.file_info(),
      status.component.diagnostics(),
      status.component.file_info {
        file_icon = false,
        filename = { modify = ":." },
        filetype = false,
        file_modified = false,
        file_read_only = false,
        surround = false,
        update = "BufEnter",
      },
      status.component.breadcrumbs {
        icon = { hl = true },
        -- hl = status.hl.get_attributes("winbar", true),
        prefix = true,
        padding = { left = 0 },
      },
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.lsp(),
      status.component.virtual_env(),
      -- Add the custom selection count component
      {
        provider = selection_count,
        hl = { bold = true },
        update = { "ModeChanged", "CursorMoved", "CursorMovedI" },
      },
      status.component.treesitter(),
      status.component.nav(),
    }
    opts.winbar = nil
  end,
}
