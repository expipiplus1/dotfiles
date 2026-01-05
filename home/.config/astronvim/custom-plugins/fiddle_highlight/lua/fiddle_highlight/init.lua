local M = {}

local ns = vim.api.nvim_create_namespace "fiddle_lua_injection"

-- Debug helper
local function dbg(...)
  local args = { ... }
  local parts = {}
  for i, v in ipairs(args) do
    parts[i] = vim.inspect(v)
  end
  vim.notify("[fiddle] " .. table.concat(parts, " "), vim.log.levels.INFO)
end

function M.apply_fiddle_highlighting(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  dbg("apply_fiddle_highlighting called for buffer", bufnr)

  local filename = vim.api.nvim_buf_get_name(bufnr)
  dbg("filename:", filename)

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  dbg("total lines:", #lines)

  local in_fiddle = false
  local fiddle_start = nil
  local lua_lines_found = 0
  local extmarks_applied = 0

  for lnum, line in ipairs(lines) do
    -- Check for FIDDLE block start
    if line:match "#if%s+0.-FIDDLE TEMPLATE" then
      in_fiddle = true
      fiddle_start = lnum
      dbg("FIDDLE block START at line", lnum, ":", line:sub(1, 60))
    elseif in_fiddle and (line:match "^#else" or line:match "^#endif") then
      dbg("FIDDLE block END at line", lnum, "started at", fiddle_start)
      in_fiddle = false
      fiddle_start = nil
    elseif in_fiddle and line:match "^%%" then
      lua_lines_found = lua_lines_found + 1
      local lua_code = line:sub(2) -- Strip leading %
      local col_offset = 1 -- Account for the %

      dbg("Lua line", lnum, ":", lua_code:sub(1, 50))

      -- Parse as Lua and apply highlights
      local ok, parser = pcall(vim.treesitter.get_string_parser, lua_code, "lua")
      dbg("  parser ok:", ok, "parser:", parser)

      if ok and parser then
        local parse_ok, trees = pcall(function() return parser:parse() end)
        dbg("  parse ok:", parse_ok, "trees:", trees and #trees or "nil")

        if parse_ok and trees and trees[1] then
          local tree = trees[1]
          local root = tree:root()
          dbg("  root node:", root and root:type() or "nil")

          local query_ok, query = pcall(vim.treesitter.query.get, "lua", "highlights")
          dbg("  query ok:", query_ok, "query:", query and "exists" or "nil")

          if query_ok and query then
            local capture_count = 0
            for id, node, metadata in query:iter_captures(root, lua_code, 0, -1) do
              capture_count = capture_count + 1
              local name = query.captures[id]
              local sr, sc, er, ec = node:range()

              if capture_count <= 3 then -- Only log first few
                dbg("    capture:", name, "range:", sc, "-", ec, "text:", lua_code:sub(sc + 1, ec))
              end

              local extmark_ok, err = pcall(
                function()
                  vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, sc + col_offset, {
                    end_col = ec + col_offset,
                    hl_group = "@" .. name .. ".lua",
                    priority = 200,
                  })
                end
              )

              if extmark_ok then
                extmarks_applied = extmarks_applied + 1
              else
                dbg("    extmark ERROR:", err)
              end
            end
            dbg("  captures for this line:", capture_count)
          end
        end
      else
        dbg "  parser creation failed"
      end
    end
  end

  dbg("Summary: lua_lines_found =", lua_lines_found, "extmarks_applied =", extmarks_applied)

  if not fiddle_start and lua_lines_found == 0 then
    dbg "WARNING: No FIDDLE block found. Checking patterns manually..."
    for i, line in ipairs(lines) do
      if line:match "FIDDLE" then dbg("  Line", i, "contains FIDDLE:", line:sub(1, 70)) end
      if line:match "^%%" then dbg("  Line", i, "starts with %%:", line:sub(1, 50)) end
    end
  end
end

function M.setup()
  dbg "setup() called"

  local group = vim.api.nvim_create_augroup("FiddleLuaHighlight", { clear = true })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged" }, {
    group = group,
    pattern = { "*.cpp", "*.h" },
    callback = function(ev)
      dbg("autocmd triggered:", ev.event, "buf:", ev.buf, "file:", ev.file)
      M.apply_fiddle_highlighting(ev.buf)
    end,
  })

  -- Also run immediately on current buffer if it matches
  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file:match "%.cpp$" or current_file:match "%.h$" then
    dbg "Running immediately on current buffer"
    M.apply_fiddle_highlighting(0)
  end

  dbg "setup() complete"
end

-- Manual trigger for testing
function M.test()
  dbg "Manual test triggered"
  M.apply_fiddle_highlighting(0)
end

return M
