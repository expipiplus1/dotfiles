{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "zsh" {
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "gitfast" "vi-mode" "safe-paste" ];
    };
    plugins = let
      p = name: {
        inherit name;
        src = "${pkgs."zsh-${name}"}/share/zsh/site-functions";
      };
    in builtins.map p [ "fast-syntax-highlighting" ];
    autosuggestion.enable = true;
    history = {
      share = false;
      size = 2000000000;
      save = 2000000000;
      ignoreDups = true;
      extended = true;
    };
    shellAliases = {
      cb = "cabal build -j8";
      nb = "IN_NIX_SHELL= nix-build -j8";
      ne = "nix-env -f '<nixpkgs>'";
      ls = "lsd";
      df = "duf";
    };
    localVariables = {
      HYPHEN_INSENSITIVE = "true";
      DISABLE_AUTO_UPDATE = "true";
    };
    initExtraBeforeCompInit = ''
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
        ${pkgs.cached-nix-shell}/bin/cached-nix-shell --keep XDG_DATA_DIRS --command "IN_NIX_SHELL=impure exec zsh; return" "$@"
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
        highlight red 'Failure\|Error\|error' | highlight green 'Success' | highlight yellow 'Warning\|warn'
      }

      function mean-and-sample-std-dev () {
        col=''${1:-0}
        awk -f <(cat <<EOF
        {
          sum+=\$$col
          a[NR]=\$$col
        }
        END{
          split("₀₁₂₃₄₅₆₇₈₉", smalls, "")
          for(i in a){
            y+=(a[i]-(sum/NR))^2

            s="x"
            split(i, digits, "")
            for (d in digits){
              s=s smalls[digits[d]+1]
            }
            print s "=" a[i]
          }
          print ""
          print "s="sqrt(y/(NR-1))
          print "x̄="sum/NR
        }
      EOF
      )
      }

    '';
    initExtra = ''
      # if [ -f ~/.config/light ]; then
      #   light
      # else
      #   dark
      # fi

      unsetopt AUTO_CD

      unset RPS1

      setopt histignorespace
      setopt inc_append_history

      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=12"
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
      character.success_symbol = "[\\$](bold green)";
      character.error_symbol = "[\\$](bold red)";
      package.disabled = true;
      aws.disabled = true;
      cmake.disabled = true;

      directory = {
        truncate_to_repo = false;
        truncation_length = 0;
      };

      lua.disabled = true;

      c.disabled = true;

      nix_shell = {
        disabled = false;
        style = "fg:yellow dimmed";
        symbol = "\\[nix-shell\\]";
        format = "[$symbol]($style) ";
      };
      haskell.disabled = true;

      git_branch = { symbol = ""; };
      git_status = { disabled = true; };
      username.format = "[$user]($style)@";
      hostname.format = "[$hostname]($style) in ";

      custom.direnv = {
        disabled = false;
        format = "[\\[direnv\\]]($style) ";
        style = "fg:yellow dimmed";
        when = "env | grep -E '^DIRENV_FILE='";
      };

      custom.jj = {
        command = ''
          jj log -r@ -l1 --ignore-working-copy --no-graph --color always  -T '
            separate(" ",
              branches.map(|x| if(
                  x.name().substr(0, 10).starts_with(x.name()),
                  x.name().substr(0, 10),
                  x.name().substr(0, 9) ++ "…")
                ).join(" "),
              tags.map(|x| if(
                  x.name().substr(0, 10).starts_with(x.name()),
                  x.name().substr(0, 10),
                  x.name().substr(0, 9) ++ "…")
                ).join(" "),
              surround("\"","\"",
                if(
                   description.first_line().substr(0, 24).starts_with(description.first_line()),
                   description.first_line().substr(0, 24),
                   description.first_line().substr(0, 23) ++ "…"
                )
              ),
              if(conflict, "conflict"),
              if(divergent, "divergent"),
              if(hidden, "hidden"),
            )
          '
        '';
        detect_folders = [ ".jj" ];
      };

      custom.jjstate = {
        detect_folders = [ ".jj" ];
        command = ''
          jj log -r@ -l1 --no-graph -T "" --stat | tail -n1 | sd "(\d+) files? changed, (\d+) insertions?\(\+\), (\d+) deletions?\(-\)" " ''${1}m ''${2}+ ''${3}-" | sd " 0." ""
        '';
      };
    };
  };
}
