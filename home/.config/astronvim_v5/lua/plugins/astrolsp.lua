-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

function dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then k = '"' .. k .. '"' end
      s = s .. "[" .. k .. "] = " .. dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

local function open_lsp_browser_link(link_type)
  -- First, try to go to definition
  local definition_found = false
  vim.lsp.buf.definition {
    on_list = function()
      definition_found = true
      vim.lsp.buf.definition()
    end,
  }

  -- We can get here before the on_list function is called which is
  -- because I don't know how to run the definition call synchronously, just
  -- check this variable again a bit later :shrug:

  local function make_hover_request(retry)
    -- If definition is found, we're done
    if definition_found then return end

    -- If no definition, proceed with hover request
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result, _, _)
      if err or not result or not result.contents then
        if not retry then print "No hover information available" end
        return
      end

      local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
      local uri

      for _, line in ipairs(markdown_lines) do
        if vim.startswith(line, "[" .. link_type .. "]") then
          uri = string.match(line, "%[" .. link_type .. "%]%((.+)%)")
          if uri then
            if uri then
              local OS = require "haskell-tools.os"
              OS.open_browser(uri)
              print("Opening " .. link_type .. " in browser")
            end
            return
          end
        end
      end

      if not retry then
        -- If we didn't find the link, try once more
        vim.defer_fn(function() make_hover_request(true) end, 100)
      else
        print("Could not find " .. link_type .. " link")
      end
    end)
  end
  make_hover_request(false)
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = true, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
        -- "cmake",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      "bashls",
      "clangd",
      -- "hls",
      "lua_ls",
      "marksman",
      "nil_ls",
      "rust_analyzer",
      "cmake",
      "slangd",
      "pylsp",
    },
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      clangd = { capabilities = { offsetEncoding = "utf-8" } },
      cmake = {
        init_options = {
          buildDirectory = "build",
          formatProgram = "gersemi",
          formatArgs = { "--definitions", "cmake", "--", "-" },
        },
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
      -- function(server, opts) require("lspconfig")[server].setup(opts) end

      -- the key is the server that is being setup with `lspconfig`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
    },
    lsp_handlers = {
      -- TODO: Does this correctly handle requests which require a response...?
      ["window/showMessage"] = vim.lsp.with(function(err, result, ctx, config)
        local sev = {
          vim.log.levels.ERROR,
          vim.log.levels.WARN,
          vim.log.levels.INFO,
          vim.log.levels.INFO, -- DEBUG messages don't show up
        }
        local title = vim.lsp.get_client_by_id(ctx.client_id).name
        require("astrocore").notify(result.message, sev[result.type], { title = title })
      end, {}),
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        ["<Leader>fs"] = {
          function()
            local opts = {}
            require("telescope.builtin").lsp_dynamic_workspace_symbols(opts)
          end,
          desc = "Find workspace symbols",
          cond = function(client) return client.supports_method "workspace/symbols" end,
        },
        gd = {
          function()
            local clients = vim.lsp.get_clients { bufnr = 0 }
            local has_hls_with_capabilities = false

            if vim.bo.filetype == "haskell" then
              for _, client in ipairs(clients) do
                if client.supports_method "textDocument/hover" and client.supports_method "textDocument/definition" then
                  has_hls_with_capabilities = true
                  break
                end
              end
            end

            if has_hls_with_capabilities then
              open_lsp_browser_link "Documentation"
            else
              vim.lsp.buf.definition()
            end
          end,
          desc = "Go to definition or open documentation",
        },
        ["<Leader>lo"] = {
          function() open_lsp_browser_link "Source" end,
          desc = "Open source",
          cond = function(client)
            return vim.bo.filetype == "haskell"
              and (client.supports_method "textDocument/hover" or client.supports_method "textDocument/definition")
          end,
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
        ["<Leader>lA"] = {
          function()
            vim.lsp.buf.code_action {
              range = {
                start = { 1, 0 },
                ["end"] = { vim.fn.line "$", 0 },
              },
            }
          end,
          desc = "All code actions in buffer",
        },
        ["<Leader>lu"] = {
          function()
            vim.lsp.buf.code_action {
              range = {
                start = { 1, 0 },
                ["end"] = { vim.fn.line "$", 0 },
              },
              context = {
                only = { "quickfix" },
              },
              filter = function(action) return action.title == "Remove all redundant imports" end,
              apply = true,
            }
          end,
          desc = "Remove all redundant imports",
          cond = function() return vim.bo.filetype == "haskell" end,
        },
        ["<leader>lh"] = {
          function()
            local bufnr = 0 -- 0 represents the current buffer
            local diagnostics = vim.diagnostic.get(bufnr)
            local formatted_diagnostics = {}

            for _, diag in ipairs(diagnostics) do
              table.insert(formatted_diagnostics, {
                range = {
                  start = { line = diag.lnum - 1, character = diag.col - 1 },
                  ["end"] = { line = diag.end_lnum - 1, character = diag.end_col - 1 },
                },
                severity = diag.severity,
                message = diag.message,
                source = diag.source,
                code = diag.code,
              })
            end

            vim.lsp.buf.code_action {
              range = {
                start = { 1, 0 },
                ["end"] = { vim.fn.line "$", 0 },
              },
              context = {
                diagnostics = formatted_diagnostics,
                only = { "quickfix" },
              },
              filter = function(action) return action.title == "Apply all hints" end,
              apply = true,
            }
          end,
          desc = "Apply all hints",
          cond = function() return vim.bo.filetype == "haskell" end,
        },
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
