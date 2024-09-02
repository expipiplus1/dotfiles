{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "treesitter" (let
  luaConfig = lua: ''
    lua <<EOF
    ${lua}
    EOF
  '';

in with pkgs.vimPlugins; {
  programs.neovim.plugins = [
    nvim-treesitter-textobjects
    {
      plugin = nvim-treesitter.withAllGrammars;
      type = "lua";
      config = ''
        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = vim.g.vscode == nil,
            disable = {"lua"},
            number = {
              color = 94,
              bold = true,
            },
          },
        }
        local vim = vim
        local opt = vim.opt

        opt.foldmethod = "expr"
        opt.foldexpr = "nvim_treesitter#foldexpr()"
        -- Disable folding at startup.
        opt.foldenable = false
      '';
    }
    {
      # plugin = nvim-treesitter-context;
      plugin = pkgs.vimUtils.buildVimPlugin {
        name = "nvim-treesitter-context";
        src = pkgs.fetchFromGitHub {
          owner = "nvim-treesitter";
          repo = "nvim-treesitter-context";
          sha256 = "0x1zc683m3awvvmq8b87dllycpcnrmvmx8fkkzx2hlii1k6a8j2s";
          rev = "0f3332788e0bd37716fbd25f39120dcfd557c90f";
        };
      };
      config = luaConfig ''
        require'treesitter-context'.setup{
          enable = true,
          max_lines = 4,
        }
      '' + ''
        hi! def link TreesitterContext StatusLine
      '';
    }
    {
      plugin = nvim-ts-context-commentstring;
      type = "lua";
      config = ''
        vim.g.skip_ts_context_commentstring_module = true
        require('ts_context_commentstring').setup {
          enable = true,
          enable_autocmd = false,
          languages = {
            css = '// %s',
            c = '// %s',
            cpp = '// %s',
            vhdl = '-- %s',
            haskell = '-- %s',
            json = '// %s',
            hlsl = '// %s',
            slang = '// %s',
            bash = '# %s',
          }
        }
      '';
    }
    {
      plugin = (pkgs.vimUtils.buildVimPlugin {
        name = "tree-sitter-playground";
        src = pkgs.fetchFromGitHub {
          owner = "nvim-treesitter";
          repo = "playground";
          rev = "4044b53c4d4fcd7a78eae20b8627f78ce7dc6f56";
          sha256 = "11h0fi469fdjck318sa4fr4d4l1r57z3phhna6kclryz4mbjmk3v";
        };
      });
      config = luaConfig ''
        require "nvim-treesitter.configs".setup {
          playground = {
            enable = true,
            disable = {},
            updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
            persist_queries = false, -- Whether the query persists across vim sessions
            keybindings = {
              toggle_query_editor = 'o',
              toggle_hl_groups = 'i',
              toggle_injected_languages = 't',
              toggle_anonymous_nodes = 'a',
              toggle_language_display = 'I',
              focus_language = 'f',
              unfocus_language = 'F',
              update = 'R',
              goto_node = '<cr>',
              show_help = '?',
            },
          }
        }
      '';
    }
    {
      plugin = mini-nvim;
      type = "lua";
      config = ''
        -- require('mini.pairs').setup({
        --   mappings = {
        --     ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\][\n ]' },
        --     ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\][\n ]' },
        --     ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\][\n ]' },
        --
        --     [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\][\n ]' },
        --     [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\][\n ]' },
        --     ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\][\n ]' },
        --
        --     ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\][\n ]', register = { cr = false } },
        --     ["'"] = { action = 'closeopen', pair = "'''", neigh_pattern = '[^%a\\][\n ]', register = { cr = false } },
        --     ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\][\n ]', register = { cr = false } },
        --   },
        -- })
        require('mini.comment').setup({
          options = {
            custom_commentstring = function()
              return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
            end,
          },
        })
      '';
    }
    {
      plugin = (pkgs.vimUtils.buildVimPlugin {
        name = "iswap";
        src = pkgs.fetchFromGitHub {
          owner = "mizlan";
          repo = "iswap.nvim";
          rev = "f4935e477c3dd8914a008884c4d83388d024487a";
          sha256 = "1zjwjmljns4pi578jm2f44gz3xxqfyk1bdfb8cnmxx23lg78n4vh";
        };
      });
      config = luaConfig ''
        require("iswap").setup({
          move_cursor = true,
        })
        vim.cmd[[
          nmap <leader>[ <Cmd>ISwapWithLeft<CR>
          nmap <leader>] <Cmd>ISwapWithRight<CR>
        ]]
      '';
    }
  ];
})
