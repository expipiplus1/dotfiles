local M = {}

local ns = vim.api.nvim_create_namespace "fiddle_lua_injection"

function M.apply_fiddle_highlighting(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local in_fiddle = false

  for lnum, line in ipairs(lines) do
    if line:match "#if%s+0.-FIDDLE TEMPLATE" then
      in_fiddle = true
    elseif in_fiddle and (line:match "^#else" or line:match "^#endif") then
      in_fiddle = false
    elseif in_fiddle and line:match "^%%" then
      local lua_code = line:sub(2) -- Strip leading %
      local col_offset = 1 -- Account for the %

      -- Parse as Lua and apply highlights
      local ok, parser = pcall(vim.treesitter.get_string_parser, lua_code, "lua")
      if ok then
        local tree = parser:parse()[1]
        local query = vim.treesitter.query.get("lua", "highlights")
        if query then
          for id, node in query:iter_captures(tree:root(), lua_code, 0, -1) do
            local name = query.captures[id]
            local sr, sc, er, ec = node:range()
            vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, sc + col_offset, {
              end_col = ec + col_offset,
              hl_group = "@" .. name .. ".lua",
              priority = 200, -- Higher than treesitter default
            })
          end
        end
      end
    end
  end
end

function M.setup()
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "TextChanged" }, {
    pattern = { "*.cpp", "*.h" },
    callback = function(ev) M.apply_fiddle_highlighting(ev.buf) end,
  })
end

return M
