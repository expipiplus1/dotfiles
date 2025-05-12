-- from: https://github.com/rosstang/dimit.nvim

local M = {}

M.config = {
  bgcolor = nil, -- Allow user to override
  highlight_group = "Dimit",
  auto_dim = true,
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
    "VertSplit",
    "Whitespace",
    "WinBarNC",
    "WinSeparator",
  },
}

local function get_highlight_value(dim_elements, hlgroup)
  return table.concat(dim_elements, ":" .. hlgroup .. ",") .. ":" .. hlgroup
end

local function merge_tb(default, new) return vim.tbl_deep_extend("force", default, new) end

local function get_color_column_bg()
  local color = vim.api.nvim_get_hl_by_name("ColorColumn", true).background
  return color and string.format("#%06x", color) or "#303030"
end

local function is_popup(win_id)
  local config = vim.api.nvim_win_get_config(win_id)
  return config.relative ~= "" or config.external or config.zindex ~= nil
end

local function undimmable(win_id)
  local buf = vim.api.nvim_win_get_buf(win_id)
  local active_config = vim.api.nvim_win_get_config(0)

  return (vim.bo[buf].buftype == "quickfix")
    or is_popup(win_id)
    -- Keep neo-tree visible while filtering
    or (vim.bo[buf].filetype == "neo-tree" and active_config.relative ~= "")
end

local function update_dimit_highlight()
  local bgcolor = M.config.bgcolor or get_color_column_bg()
  vim.api.nvim_set_hl(0, M.config.highlight_group, { bg = bgcolor })
end

-- Track the last active non-popup window
M.last_normal_win = nil

M.dim_inactive = function()
  update_dimit_highlight()

  local current = vim.api.nvim_get_current_win()

  -- If current window is a popup, use the last normal window as the active one
  if is_popup(current) then
    if M.last_normal_win and vim.api.nvim_win_is_valid(M.last_normal_win) then current = M.last_normal_win end
  else
    -- Update the last normal window
    M.last_normal_win = current
  end

  local dim_value = get_highlight_value(M.config.dim_elements, M.config.highlight_group)

  for _, w in pairs(vim.api.nvim_list_wins()) do
    if not undimmable(w) then
      local winhighlights = current == w and "" or dim_value
      vim.api.nvim_set_option_value("winhighlight", winhighlights, { win = w })
    end
  end
end

M.setup = function(opts)
  opts = opts == nil and {} or opts
  M.config = merge_tb(M.config, opts)

  update_dimit_highlight()
  M.dim_inactive()

  vim.api.nvim_create_user_command("Dimit", M.dim_inactive, {})

  if not M.config.auto_dim then return end

  if M.win_enter_autocmd ~= nil then vim.api.nvim_del_autocmd(M.win_enter_autocmd) end
  if M.focus_lost_autocmd ~= nil then vim.api.nvim_del_autocmd(M.focus_lost_autocmd) end
  if M.focus_gained_autocmd ~= nil then vim.api.nvim_del_autocmd(M.focus_gained_autocmd) end
  if M.colorscheme_autocmd ~= nil then vim.api.nvim_del_autocmd(M.colorscheme_autocmd) end

  local focus_lost = false

  M.win_enter_autocmd = vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "WinClosed" }, {
    callback = function()
      local current = vim.api.nvim_get_current_win()

      -- Skip dimming if entering a popup window
      if is_popup(current) then return end

      if not focus_lost then M.dim_inactive() end
    end,
  })

  M.focus_lost_autocmd = vim.api.nvim_create_autocmd({ "FocusLost" }, {
    callback = function()
      focus_lost = true
      local dim_value = get_highlight_value(M.config.dim_elements, M.config.highlight_group)
      for _, w in pairs(vim.api.nvim_list_wins()) do
        if not undimmable(w) then vim.api.nvim_set_option_value("winhighlight", dim_value, { win = w }) end
      end
    end,
  })

  M.focus_gained_autocmd = vim.api.nvim_create_autocmd({ "FocusGained" }, {
    callback = function()
      focus_lost = false
      M.dim_inactive()
    end,
  })

  M.colorscheme_autocmd = vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      if not M.config.bgcolor then
        update_dimit_highlight()
        M.dim_inactive()
      end
    end,
  })
end

return M
