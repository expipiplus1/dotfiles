{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "kakoune" {
  programs.kakoune = {
    enable = true;
    plugins = with pkgs.kakounePlugins; [
      kak-lsp
      prelude-kak
      connect-kak

    ];
    extraConfig = ''
      # Init kak-lsp
      eval %sh{kak-lsp --kakoune -s $kak_session}  # Not needed if you load it with plug.kak.
      lsp-enable

      set-option global ui_options terminal_assistant=cat

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
              tmux-terminal-impl 'display-popup -E -h 70% -w 90% -d #{pane_current_path}' %arg{@}
          }
      }

      ####
      # Modules
      require-module connect-fzf

      hook global ModuleLoaded tmux %{
            alias global popup tmux-terminal-popup
      }

      # Explore files and buffers with fzf
      alias global explore-files fzf-files
      alias global explore-buffers fzf-buffers

      # mappings
      map global user f :explore-files<ret>

      map global user l %{:enter-user-mode lsp<ret>} -docstring "LSP mode"

      face global InfoDefault               Information
      face global InfoBlock                 Information
      face global InfoBlockQuote            Information
      face global InfoBullet                Information
      face global InfoHeader                Information
      face global InfoLink                  Information
      face global InfoLinkMono              Information
      face global InfoMono                  Information
      face global InfoRule                  Information
      face global InfoDiagnosticError       Information
      face global InfoDiagnosticHint        Information
      face global InfoDiagnosticInformation Information
      face global InfoDiagnosticWarning     Information
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
