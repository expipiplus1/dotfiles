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
    owner = "chriskempson";
    repo = "base16-shell";
    rev = "ce8e1e540367ea83cc3e01eec7b2a11783b3f9e1";
    sha256 = "1yj36k64zz65lxh28bb5rb5skwlinixxz6qwkwaf845ajvm45j1q";
  };

in {
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "vi-mode" ];
    };
    plugins = let
      p = name: {
        inherit name;
        src = "${pkgs."zsh-${name}"}/share/zsh/site-functions";
      };
    in [ (p "fast-syntax-highlighting") ];
    enableAutosuggestions = true;
    history = {
      share = false;
      size = 1000000;
      save = 1000000;
      ignoreDups = true;
      extended = true;
    };
    shellAliases = {
      cb = "cabal build -j8";
      nb = "IN_NIX_SHELL= nix-build -j8";
      ne = "nix-env -f '<nixpkgs>'";
    };
    localVariables = {
      HYPHEN_INSENSITIVE = "true";
      DISABLE_AUTO_UPDATE = "true";
    };
    initExtraBeforeCompInit = ''
      function light()
      {
        touch ~/.config/light
        . ${base16}/scripts/base16-solarized-light.sh
        if command -v gsettings 2>&1 >/dev/null; then
          # profile=''${"$(gsettings get org.gnome.Terminal.ProfilesList default)":1:-1}
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-color "#EEE8D5"
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" foreground-color "#586E75"
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color       "#586E75"
        fi
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-active-style "bg=colour0"
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-style "bg=colour18"
      }

      function dark()
      {
        if [ -f ~/.config/light ]; then
          rm ~/.config/light
        fi
        . ${base16}/scripts/base16-tomorrow-night.sh
        if command -v gsettings 2>&1 >/dev/null; then
          # profile=''${"$(gsettings get org.gnome.Terminal.ProfilesList default)":1:-1}
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-color "#282A2E"
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" foreground-color "#C5C8C6"
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color       "#C5C8C6"
        fi
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-active-style bg=colour0
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
        ${pkgs.cached-nix-shell}/bin/cached-nix-shell --keep XDG_DATA_DIRS --command "IN_NIX_SHELL=1 exec zsh; return" "$@"
      }

      c2n(){
        cp -v -n "$HOME/dotfiles/nix-haskell-skeleton/default.nix" .
      }

      sr(){
        ${pkgs.silver-searcher}/bin/ag -0 -l $1 | xargs -0 perl -pi -e "s/$1/$2/g"
      }

      ss() {
        find "$@" -mindepth 1 -maxdepth 1 -print0 | xargs -0 du -sh | sort -h
      }

      function nix-source() {
        git remote get-url origin |
          sed 's|\.git||' |
          awk -F '/|:' '{print $(NF-1),"\t",$NF}' |
          read owner repo &&
          ${pkgs.nix-prefetch-github}/bin/nix-prefetch-github --prefetch --nix --rev $(git rev-parse HEAD) $owner $repo
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

      setopt histignorespace
      setopt inc_append_history
      bindkey -M vicmd 'k' history-substring-search-up
      bindkey -M vicmd 'j' history-substring-search-down

      bindkey '^f' autosuggest-accept

      bindkey "''${terminfo[khome]}" beginning-of-line
      bindkey "''${terminfo[kend]}"  end-of-line
      bindkey "''${terminfo[kich1]}" overwrite-mode
      bindkey "''${terminfo[kdch1]}" delete-char
      bindkey "''${terminfo[kcuu1]}" up-line-or-history
      bindkey "''${terminfo[kcud1]}" down-line-or-history
      bindkey "''${terminfo[kcub1]}" backward-char
      bindkey "''${terminfo[kcuf1]}" forward-char
    '';

    # So ssh machine -- foo works
    envExtra = ''
      # set PATH so it includes user's private bin directories
      PATH="$HOME/bin:$HOME/.local/bin:$PATH"
      if [ -z ''${NIX_PROFILES+x} ]; then
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then
          . $HOME/.nix-profile/etc/profile.d/nix.sh;
        fi
      fi
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      character.symbol = "$";
      package.disabled = true;

      directory = {
        truncate_to_repo = false;
        truncation_length = 0;
      };

      nix_shell = {
        disabled = false;
        use_name = false;
        impure_msg = "";
        pure_msg = "";
        symbol = "[nix-shell]";
        style = "bold green";
      };

      git_branch = { symbol = ""; };
      git_status = { disabled = true; };
    };
  };
}
