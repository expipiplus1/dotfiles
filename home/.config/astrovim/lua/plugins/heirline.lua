local function is_bottom_right_window()
  local win_count = vim.fn.winnr "$"
  local current_win = vim.fn.winnr()
  -- Assuming a simple grid layout, the bottom-right window is the last window
  return current_win == win_count
end

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
  dependencies = {
    { -- configure AstroUI to include a new UI icon
      "AstroNvim/astroui",
      ---@type AstroUIOpts
      opts = {
        icons = {
          Clock = "", -- add icon for clock
        },
      },
    },
  },
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
        prefix = true,
        padding = { left = 0 },
      },
      status.component.fill(),
      status.component.cmd_info(),
      status.component.fill(),
      status.component.lsp(),
      status.component.virtual_env(),
      {
        provider = selection_count,
        hl = { bold = true },
        update = { "ModeChanged", "CursorMoved", "CursorMovedI" },
      },
      status.component.treesitter(),
      status.component.nav(),
      status.component.builder {
        {
          provider = function()
            if is_bottom_right_window() then
              local time = os.date "%H:%M"
              return status.utils.stylize(time, {
                icon = { kind = "Clock", padding = { right = 1 } },
                padding = { right = 1 },
              })
            end
            return ""
          end,
        },
        update = {
          "User",
          "ModeChanged",
          callback = vim.schedule_wrap(function(_, args)
            if
              (args.event == "User" and args.match == "UpdateTime")
              or (args.event == "ModeChanged" and args.match:match ".*:.*")
            then
              vim.cmd.redrawstatus()
            end
          end),
        },
        hl = status.hl.get_attributes "mode",
        surround = { separator = "right", color = status.hl.mode_bg },
      },
    }
    opts.winbar = nil

    vim.uv.new_timer():start(
      (60 - tonumber(os.date "%S")) * 1000,
      60000,
      vim.schedule_wrap(function() vim.api.nvim_exec_autocmds("User", { pattern = "UpdateTime", modeline = false }) end)
    )
  end,
}
