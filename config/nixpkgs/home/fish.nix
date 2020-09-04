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
    owner = "tomyun";
    repo = "base16-fish";
    rev = "675d53a0dd1aed0fc5927f26a900f5347d446459";
    sha256 = "0lp1s9hg682jwzqn1lgj5mrq5alqn9sqw75gjphmiwmciv147kii";
  };

in {
  programs.fish = {
    enable = true;
    shellAbbrs = {
      cb = "cabal build -j8";
      nb = "IN_NIX_SHELL= nix-build -j8";
      ne = "nix-env -f <nixpkgs>";
    };
    shellInit = ''
      function light
        touch ~/.config/light
        TMUX= base16-solarized-light
        if command -v gsettings 2>&1 >/dev/null;
          # profile=''${"(gsettings get org.gnome.Terminal.ProfilesList default)":1:-1}
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-color "#EEE8D5"
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" foreground-color "#586E75"
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color       "#586E75"
        end
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-active-style "bg=colour0"
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-style "bg=colour18"
      end

      function dark
        if [ -f ~/.config/light ]
          rm ~/.config/light
        end
        TMUX= base16-tomorrow-night
        if command -v gsettings 2>&1 >/dev/null
          # profile=''${"(gsettings get org.gnome.Terminal.ProfilesList default)":1:-1}
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" background-color "#282A2E"
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" foreground-color "#C5C8C6"
          # gsettings set "org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/" bold-color       "#C5C8C6"
        end
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-active-style bg=colour0
        ${config.programs.tmux.package}/bin/tmux set-window-option -g window-style bg=colour18
      end

      if command -v xdg-open 2>&1 >/dev/null
        function open
          xdg-open $argv 2> /dev/null
        end
      end

      function md2pdf
        nix-shell -j8 -p pandocEnv --command "pandoc -t latex --latex-engine=xelatex -o $argv[1].pdf $argv[1]"
      end

      function printer
        lp -o sides=two-sided-long-edge $argv
      end

      function ns
        ${pkgs.cached-nix-shell}/bin/cached-nix-shell --keep XDG_DATA_DIRS --command "IN_NIX_SHELL=1 exec fish; return" $argv
      end

      function c2n
        cp -v -n "$HOME/dotfiles/nix-haskell-skeleton/default.nix" .
      end

      function sr
        ${pkgs.silver-searcher}/bin/ag -0 -l $argv[1] | xargs -0 perl -pi -e "s/$argv[1]/$argv[2]/g"
      end

      function ss
        find $argv -mindepth 1 -maxdepth 1 -print0 | xargs -0 du -sh | sort -h
      end

      function nix-source
        git remote get-url origin |
          sed 's|\.git||' |
          awk -F '/|:' '{print $(NF-1),"\t",$NF}' |
          read owner repo &&
            ${pkgs.nix-prefetch-github}/bin/nix-prefetch-github --prefetch --nix --rev (git rev-parse HEAD) $owner $repo
      end

      function highlight
        set fg_color_map[black] 30
        set fg_color_map[red] 31
        set fg_color_map[green] 32
        set fg_color_map[yellow] 33
        set fg_color_map[blue] 34
        set fg_color_map[magenta] 35
        set fg_color_map[cyan] 36

        set fg_c (echo -e "\e[1;''$fg_color_map[$argv[1]]m")
        set c_rs "\e[0m"
        sed -u s"/$argv[2]/$fg_c\0$c_rs/gI"
      end

      function color-results
        highlight red 'Failure\|Error' | highlight green 'Success' | highlight yellow 'Warning'
      end

      #
      # Vars
      #
      set --export FZF_DEFAULT_COMMAND "${pkgs.fd}/bin/fd"
    '';

    interactiveShellInit = ''
      set fish_greeting

      source ${base16}/functions/base16-tomorrow-night.fish
      source ${base16}/functions/base16-solarized-light.fish

      if [ -f ~/.config/light ]
        light
      else
        dark
      end

      #
      # Vi keybindings
      #
      function hybrid_bindings --description "Vi-style bindings that inherit emacs-style bindings in all modes"
          for mode in default insert visual
              fish_default_key_bindings -M $mode
          end
          fish_vi_key_bindings --no-erase
      end
      set -g fish_key_bindings hybrid_bindings

      set --export FZF_DEFAULT_COMMAND '${pkgs.fd}/bin/fd --type f'
      set --export FZF_DEFAULT_OPTS '--bind ctrl-j:down,ctrl-k:up'
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings= {
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

      git_branch = {
        symbol = "";
      };
      git_status = {
        disabled = true;
      };
    };
  };
}
