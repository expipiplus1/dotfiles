-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

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
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
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
