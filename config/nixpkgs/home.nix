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

in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  news.display = "silent";

  home.packages = with pkgs; [ gitAndTools.hub ];

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
          "spaceship.zsh-theme" = /home/j/dotfiles/spaceship.zsh-theme;
        };
      });
      theme = "spaceship";
      plugins =
        [ "cabal" "gitfast" "history-substring-search" "nix" "tmux" "vi-mode" ];
    };
    shellAliases = {
      git = "${pkgs.gitAndTools.hub}/bin/hub";
      gs = "git status";
      gd = "git diff";
      cb = "cabal build -j8";
      nb = "nix-build -j8";
      ne = "nix-env -f '<nixpkgs>'";
    };
    localVariables = {
      HYPHEN_INSENSITIVE = "true";
      DISABLE_AUTO_UPDATE = "true";
      ENABLE_CORRECTION = "true";
    };
    initExtraBeforeCompInit = ''
      export NIX_PATH=''${NIX_PATH:+$NIX_PATH:}home-manager=\$HOME/src/home-manager

      function light()
      {
        touch ~/.config/light
        ~/.config/base16-shell/base16-solarized.light.sh
        gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#EEE8D5"
        gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#586E75"
        tmux set-window-option -g window-active-style bg=colour15
        tmux set-window-option -g window-style bg=colour21
      }

      function dark()
      {
        if [ -f ~/.config/light ]; then
          rm ~/.config/light
        fi
        ~/.config/base16-shell/base16-tomorrow.dark.sh
        gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "#282A2E"
        gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#C5C8C6"
        tmux set-window-option -g window-active-style 'bg=black'
        tmux set-window-option -g window-style bg=colour18
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
        ag -0 -l $1 | xargs -0 perl -pi -e "s/$1/$2/g"
      }

      ss() {
        find "$@" -mindepth 1 -maxdepth 1 -print0 | xargs -0 du -sh | sort -h
      }

      wd() {
        nix-store -q --graph "$1" | dijkstra -da "$2" | gvpr -c 'N[dist>1000.0]{delete(NULL, $)}' | dot -Tsvg | display
      }

      unsetopt AUTO_CD

      unsetopt share_history
      HISTCONTROL=ignoredups:ignorespace
      HISTSIZE=10000000
      HISTFILESIZE=20000000

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

  programs.git = {
    enable = true;
    userEmail = "git@monoid.al";
    userName = "Joe Hermaszewski";
    aliases = {
      po = ''
        "!git push --set-upstream origin \"$(git rev-parse --abbrev-ref HEAD)\""'';
      s = ''"status -s"'';
      cp = ''"cherry-pick"'';
      co = ''"checkout"'';
      cob = ''"checkout -b"'';
      pr = ''"pull-request"'';
      latest = ''"!git log --all --oneline | head -n1 | cut -f1 -d' '"'';
      cpl = ''"!git cherry-pick $(git latest)"'';
      pf = ''"push --force-with-lease"'';
      authors = ''
        "!f(){ set -o pipefail; git blame $1 --line-porcelain | grep 'author ' | grep -v 'Not Committed Yet' | sed 's/author //' | sort | uniq -c | sort -n ; }; f"'';
      author = ''
        "!f(){ set -o pipefail; git blame $1 --line-porcelain | grep 'author ' | grep -v 'Not Committed Yet' | sed 's/author //' | sort | uniq -c | sort -nr | head -n1 | sed 's/ *[0-9]* *//' ; }; f"'';
      cane = ''"commit --amend --no-edit"'';
    };
    extraConfig = {
      oh-my-zsh = { only-branch = 1; };
      rebase = { instructionFormat = "[%an] %s"; };
      github = { user = "expipiplus1"; };
      mergetool = { keepBackup = false; };
      merge = { tool = "vimdiff"; };
      core = { editor = "vim"; };
      push = { default = "simple"; };
      color = { ui = "auto"; };
    };
  };
}
