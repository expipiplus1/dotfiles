local function is_bottom_right_window(self)
  local windows = vim.api.nvim_tabpage_list_wins(0)
  -- Filter out floating windows
  local normal_windows = {}
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_get_config(win).relative == "" then table.insert(normal_windows, win) end
  end
  local is_bottom_right = self.winid == normal_windows[#normal_windows]
  return is_bottom_right
end

local function selection_count()
  local mode = vim.fn.mode(1)
  if mode:find "[vV\22]" then
    local lines = math.abs(vim.fn.line "v" - vim.fn.line ".") + 1
    return string.format(" %d lines", lines)
  end
  return ""
end

local clock_faces = {
  "🕛",
  "🕧",
  "🕐",
  "🕜",
  "🕑",
  "🕝",
  "🕒",
  "🕞",
  "🕓",
  "🕟",
  "🕔",
  "🕠",
  "🕕",
  "🕡",
  "🕖",
  "🕢",
  "🕗",
  "🕣",
  "🕘",
  "🕤",
  "🕙",
  "🕥",
  "🕚",
  "🕦",
}

local function get_clock_icon(hour, minute)
  local index = math.fmod(hour * 2 + (minute >= 30 and 1 or 0), 24)
  return clock_faces[index + 1] -- Lua arrays are 1-indexed
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
      -- status.component.treesitter(),
      status.component.nav(),
      status.component.builder {
        {
          init = function(self)
            -- Set winid for the current window
            self.winid = vim.api.nvim_get_current_win()
          end,
          provider = function(self)
            if is_bottom_right_window(self) then
              local hour = tonumber(os.date "%H")
              local minute = tonumber(os.date "%M")
              local icon = get_clock_icon(hour, minute)
              local time = tostring(os.date "%H:%M")
              return status.utils.stylize(icon .. time, {
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
