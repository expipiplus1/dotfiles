{ pkgs, ... }:

{
  programs.kakoune = {
    enable = true;
    plugins = with pkgs.kakounePlugins; [ kak-lsp ];
    extraConfig = ''
      # Init kak-lsp
      eval %sh{kak-lsp --kakoune -s $kak_session}

      # Navigate completion menu with tab
      hook global InsertCompletionShow .* %{
          try %{
              exec -draft 'h<a-K>\h<ret>'
              map window insert <s-tab> <c-p>
              map window insert <tab> <c-n>
          }
      }
      hook global InsertCompletionHide .* %{
          unmap window insert <tab> <c-n>
          unmap window insert <s-tab> <c-p>
      }

      ####
      hook global ModuleLoaded tmux %{
          define-command tmux-terminal-popup -params 1.. -shell-completion -docstring '
          tmux-terminal-popup <program> [<arguments>]: create a new terminal as a tmux popup
          The program passed as argument will be executed in the new popup' \
          %{
              tmux-terminal-impl 'display-popup -E -h 75% -d #{pane_current_path}' %arg{@}
          }
      }
    '';
  };
  xdg.configFile."kak-lsp/kak-lsp.toml".source =
    pkgs.writeText "kak-lsp.toml" ''
      [language.haskell]
      filetypes = ["haskell"]
      roots = ["Setup.hs", "stack.yaml", "*.cabal"]
      command = "haskell-language-server-wrapper"
      args = ["--lsp"]
    '';
  xdg.configFile."kak/colors/base16-tomorrow-night.kak".source =
    (pkgs.fetchFromGitHub {
      owner = "AprilArcus";
      repo = "base16-kakoune";
      rev = "c6367c5361ada121db2d0b73f8989f8c6f425697"; # update-scheme-syntax
      sha256 = "06vaknfgsvvjv5vvalg51fdxdqx72wkvjwjmlwqdx3dsvv3yaf0w";
    }) + "/colors/base16-tomorrow-night.kak";
}
