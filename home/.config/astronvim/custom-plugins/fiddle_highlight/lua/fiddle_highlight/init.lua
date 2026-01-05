local M = {}

local ns = vim.api.nvim_create_namespace "fiddle_lua_injection"

-- Find balanced parentheses starting at pos (pos points to the opening paren)
local function find_balanced_paren(str, pos)
  if str:sub(pos, pos) ~= "(" then return nil end

  local depth = 0
  for i = pos, #str do
    local c = str:sub(i, i)
    if c == "(" then
      depth = depth + 1
    elseif c == ")" then
      depth = depth - 1
      if depth == 0 then return i end
    end
  end
  return nil -- Unbalanced
end

-- Find all $(...) splices in a line
local function find_splices(line)
  local splices = {}
  local i = 1
  while i <= #line do
    local dollar_pos = line:find("%$%(", i)
    if not dollar_pos then break end
    local paren_start = dollar_pos + 1
    local paren_end = find_balanced_paren(line, paren_start)
    if paren_end then
      table.insert(splices, {
        start_col = dollar_pos - 1, -- 0-indexed, points to $
        end_col = paren_end, -- 0-indexed exclusive (after closing paren)
        lua_start = dollar_pos + 1, -- 0-indexed, start of lua content (after "$(" )
        lua_end = paren_end - 1, -- 0-indexed exclusive, end of lua content (before ")")
        lua_code = line:sub(dollar_pos + 2, paren_end - 1),
      })
      i = paren_end + 1
    else
      i = dollar_pos + 1
    end
  end
  return splices
end

local function apply_lua_highlights(bufnr, lnum, col_offset, lua_code, priority)
  local ok, parser = pcall(vim.treesitter.get_string_parser, lua_code, "lua")

  if ok and parser then
    local parse_ok, trees = pcall(function() return parser:parse() end)

    if parse_ok and trees and trees[1] then
      local tree = trees[1]
      local root = tree:root()

      local query_ok, query = pcall(vim.treesitter.query.get, "lua", "highlights")

      if query_ok and query then
        for id, node, metadata in query:iter_captures(root, lua_code, 0, -1) do
          local name = query.captures[id]
          local sr, sc, er, ec = node:range()

          vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, sc + col_offset, {
            end_col = ec + col_offset,
            hl_group = "@" .. name .. ".lua",
            priority = priority,
          })
        end
      end
    end
  end
end

local function apply_cpp_highlights(bufnr, lnum, col_start, col_end, cpp_code, priority)
  if #cpp_code == 0 then return end

  local ok, parser = pcall(vim.treesitter.get_string_parser, cpp_code, "cpp")

  if ok and parser then
    local parse_ok, trees = pcall(function() return parser:parse() end)

    if parse_ok and trees and trees[1] then
      local tree = trees[1]
      local root = tree:root()

      local query_ok, query = pcall(vim.treesitter.query.get, "cpp", "highlights")

      if query_ok and query then
        for id, node, metadata in query:iter_captures(root, cpp_code, 0, -1) do
          local name = query.captures[id]
          local sr, sc, er, ec = node:range()

          -- Only apply if within bounds
          if sc + col_start < col_end then
            vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, sc + col_start, {
              end_col = math.min(ec + col_start, col_end),
              hl_group = "@" .. name .. ".cpp",
              priority = priority,
            })
          end
        end
      end
    end
  end
end

function M.apply_fiddle_highlighting(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local in_fiddle = false

  for lnum, line in ipairs(lines) do
    local lnum0 = lnum - 1 -- 0-indexed line number

    if line:match "#if%s+0.-FIDDLE TEMPLATE" then
      in_fiddle = true
    elseif in_fiddle and (line:match "^#else" or line:match "^#endif") then
      in_fiddle = false
    elseif in_fiddle then
      if line:match "^%%" then
        -- Entire line (after %) is Lua
        local lua_code = line:sub(2)

        -- Base highlight to reset the line
        vim.api.nvim_buf_set_extmark(bufnr, ns, lnum0, 0, {
          end_col = #line,
          hl_group = "Normal",
          priority = 150,
        })

        -- Highlight the leading % as delimiter
        vim.api.nvim_buf_set_extmark(bufnr, ns, lnum0, 0, {
          end_col = 1,
          hl_group = "@punctuation.delimiter.lua",
          priority = 300,
        })

        -- Apply Lua highlighting
        apply_lua_highlights(bufnr, lnum0, 1, lua_code, 300)
      else
        -- Mixed line: C++ with $(...) Lua splices
        local splices = find_splices(line)

        -- Base highlight to reset the line
        vim.api.nvim_buf_set_extmark(bufnr, ns, lnum0, 0, {
          end_col = #line,
          hl_group = "Normal",
          priority = 150,
        })

        -- Build segments of C++ code (between splices)
        local cpp_segments = {}
        local pos = 1
        for _, splice in ipairs(splices) do
          if splice.start_col + 1 > pos then
            table.insert(cpp_segments, {
              start_col = pos - 1, -- 0-indexed
              end_col = splice.start_col, -- 0-indexed
              code = line:sub(pos, splice.start_col),
            })
          end
          pos = splice.end_col + 1
        end
        -- Remaining C++ after last splice
        if pos <= #line then
          table.insert(cpp_segments, {
            start_col = pos - 1,
            end_col = #line,
            code = line:sub(pos),
          })
        end

        -- Apply C++ highlighting to segments
        for _, seg in ipairs(cpp_segments) do
          apply_cpp_highlights(bufnr, lnum0, seg.start_col, seg.end_col, seg.code, 200)
        end

        -- Apply splice highlighting
        for _, splice in ipairs(splices) do
          -- Highlight $( as delimiter
          vim.api.nvim_buf_set_extmark(bufnr, ns, lnum0, splice.start_col, {
            end_col = splice.start_col + 2,
            hl_group = "@punctuation.bracket.lua",
            priority = 300,
          })

          -- Highlight ) as delimiter
          vim.api.nvim_buf_set_extmark(bufnr, ns, lnum0, splice.end_col - 1, {
            end_col = splice.end_col,
            hl_group = "@punctuation.bracket.lua",
            priority = 300,
          })

          -- Highlight Lua content inside
          if #splice.lua_code > 0 then apply_lua_highlights(bufnr, lnum0, splice.lua_start, splice.lua_code, 300) end
        end
      end
    end
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("FiddleLuaHighlight", { clear = true })

  vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufWinEnter",
    "BufReadPost",
    "BufWritePost",
    "TextChanged",
    "TextChangedI",
    "FileType",
  }, {
    group = group,
    pattern = { "*.cpp", "*.h", "*.hpp", "*.cc", "*.cxx" },
    callback = function(ev)
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(ev.buf) then M.apply_fiddle_highlighting(ev.buf) end
      end, 10)
    end,
  })

  -- Run on all currently open cpp buffers
  vim.defer_fn(function()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name:match "%.cpp$" or name:match "%.h$" or name:match "%.hpp$" then M.apply_fiddle_highlighting(bufnr) end
      end
    end
  end, 100)
end

function M.test() M.apply_fiddle_highlighting(0) end

return M
