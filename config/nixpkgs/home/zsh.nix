{ config, pkgs, ... }:

let
  oh-my-zsh-custom = attrs:
    let
      links = with pkgs.lib;
        concatLists (mapAttrsToList (prefix: as:
          mapAttrsToList (plugName: path: {
            inherit path;
            name = "${prefix}/" + plugName;
          }) as) attrs);

    in pkgs.linkFarm "zsh-custom" links;

  base16 = pkgs.fetchFromGitHub {
    owner = "mz026";
    repo = "base16-shell";
    rev = "773ce86a09c2d2700da39a7342df0776ebb69033";
    sha256 = "19fbc44mf0sbjhaw7dcffsignr7qzaw9fzd3k36bx4npp351vfl0";
  };

in {
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      custom = toString (oh-my-zsh-custom {
        plugins = {
          nix = pkgs.fetchFromGitHub {
            owner = "expipiplus1";
            repo = "nix-zsh-completions";
            rev = "1f5ff97e5f71d4a668d6bfaec852a108568ea8f7";
            sha256 = "138wvvwgcazgvnvyl898flz2h614z02203d2ri4724fb4xmzzif9";
          };
        };
        themes = {
          "spaceship.zsh-theme" = ./spaceship.zsh-theme;
        };
      });
      theme = "spaceship";
      plugins = [ "cabal" "history-substring-search" "nix" "vi-mode" ];
    };
    shellAliases = {
      cb = "cabal build -j8";
      nb = "nix-build -j8";
      ne = "nix-env -f '<nixpkgs>'";
    };
    localVariables = {
      HYPHEN_INSENSITIVE = "true";
      DISABLE_AUTO_UPDATE = "true";
      ENABLE_CORRECTION = "true";
      HISTCONTROL = "ignoredups:ignorespace";
      HISTSIZE = 10000000;
      HISTFILESIZE = 20000000;
    };
    initExtraBeforeCompInit = ''
      function light()
      {
        touch ~/.config/light
        ${base16}/base16-solarized.light.sh
        if command -v gsettings 2>&1 >/dev/null; then
          profile=''${"$(gsettings get org.gnome.Terminal.ProfilesList default)":1:-1}
          gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-color "#EEE8D5"
          gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" foreground-color "#586E75"
          gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color       "#586E75"
        fi
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-active-style bg=colour15
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-style bg=colour21
      }

      function dark()
      {
        if [ -f ~/.config/light ]; then
          rm ~/.config/light
        fi
        ${base16}/base16-tomorrow.dark.sh
        if command -v gsettings 2>&1 >/dev/null; then
          profile=''${"$(gsettings get org.gnome.Terminal.ProfilesList default)":1:-1}
          gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-color "#282A2E"
          gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" foreground-color "#C5C8C6"
          gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color       "#C5C8C6"
        fi
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-active-style 'bg=black'
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-style bg=colour18
      }

      if [ -f ~/.config/light ]; then
        light
      else
        dark
      fi

      if command -v xdg-open 2>&1 >/dev/null; then
        open(){
          xdg-open "$@" 2> /dev/null
        }
      fi

      md2pdf(){
        nix-shell -j8 -p pandocEnv --command "pandoc -t latex --latex-engine=xelatex -o $1.pdf $1"
      }

      printer(){
        lp -o sides=two-sided-long-edge "$@"
      }

      ns(){
        nix-shell --command "IN_NIX_SHELL=1 exec zsh; return" "$@"
      }

      c2n(){
        cp -v -n "$HOME/dotfiles/nix-haskell-skeleton/default.nix" "$HOME/dotfiles/nix-haskell-skeleton/shell.nix" .
      }

      sr(){
        ${pkgs.silver-searcher}/bin/ag -0 -l $1 | xargs -0 perl -pi -e "s/$1/$2/g"
      }

      ss() {
        find "$@" -mindepth 1 -maxdepth 1 -print0 | xargs -0 du -sh | sort -h
      }

      function highlight() {
        declare -A fg_color_map
        fg_color_map[black]=30
        fg_color_map[red]=31
        fg_color_map[green]=32
        fg_color_map[yellow]=33
        fg_color_map[blue]=34
        fg_color_map[magenta]=35
        fg_color_map[cyan]=36

        fg_c=$(echo -e "\e[1;''${fg_color_map[$1]}m")
        c_rs=$'\e[0m'
        sed -u s"/$2/$fg_c\0$c_rs/gI"
      }

      function color-results () {
        highlight red 'Failure\|Error' | highlight green 'Success' | highlight yellow 'Warning'
      }

      unsetopt AUTO_CD

      unsetopt share_history

      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down
    '';

    # So ssh machine -- foo works
    envExtra = ''
      # set PATH so it includes user's private bin directories
      PATH="$HOME/bin:$HOME/.local/bin:$PATH"
      if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
    '';
  };
}
