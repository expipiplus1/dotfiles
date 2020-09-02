{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ gitAndTools.hub tig ];
  programs.fish = {
    shellAliases = {
      git = "${pkgs.gitAndTools.hub}/bin/hub";
    };
    shellAbbrs = {
      gs = "git status";
      gd = "git diff";
    };
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
    extraConfig = rec {
      oh-my-zsh = { only-branch = 1; };
      pull = { rebase = true; };
      rebase = {
        instructionFormat = "[%an] %s";
        autoStash = true;
      };
      github = { user = "expipiplus1"; };
      "credential \"https://github.com\"".username = github.user;
      mergetool = { keepBackup = false; };
      merge = { tool = "vimdiff"; };
      core = { editor = "vim"; };
      push = { default = "simple"; };
      color = { ui = "auto"; };
    };
  };
}
