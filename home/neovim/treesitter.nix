{ config, pkgs, lib, ... }:

let
  appendPatches = patches: drv:
    drv.overrideAttrs (old: { patches = old.patches or [ ] ++ patches; });

  luaConfig = lua: ''
    lua <<EOF
    ${lua}
    EOF
  '';

in with pkgs.vimPlugins; {
  programs.neovim.plugins = [
      nvim-treesitter-textobjects
      {
        plugin = (nvim-treesitter.overrideAttrs (old: {
          src = fetchFromGitHub {
            owner = "nvim-treesitter";
            repo = "nvim-treesitter";
            rev = "10173f638594eddf658a0cb93e29506cc7f6ac01"; # pin
            sha256 = "0f865zip5valgpjd7sc60wlli2h176b7l7d7wa81k332isq2lkk5";
          };
        })).withAllGrammars;
        type = "lua";
        config = ''
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = vim.g.vscode == nil,
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
        plugin = nvim-treesitter-context;
        config = luaConfig ''
          require'treesitter-context'.setup{
            enable = true,
          }
        '' + ''
          hi! def link TreesitterContext StatusLine
        '';
      }
      {
        plugin = nvim-ts-context-commentstring;
        type = "lua";
        config = ''
          require'nvim-treesitter.configs'.setup {
            context_commentstring = {
              enable = true,
              config = {
                css = '// %s',
                c = '// %s',
                cpp = '// %s',
                vhdl = '-- %s',
                haskell = '-- %s',
                json = '// %s',
                hlsl = '// %s',
                slang = '// %s',
                bash = '# %s',
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
    ];
}
