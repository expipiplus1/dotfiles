{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ gitAndTools.hub tig ];
  programs.zsh = {
    oh-my-zsh.plugins = [ "gitfast" "github" ];
    shellAliases = {
      git = "${pkgs.gitAndTools.hub}/bin/hub";
      gap = "git add -p";
      gs = "git status";
      gsi = "git switch";
      gd = "git diff";
      gdc = "git diff --cached";
      g = "git";
      glog = "git log --oneline --graph";
      grs = "git restore --staged";
    };
  };

  programs.gpg = { enable = true; };
  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "gnome3";
  };

  programs.git = {
    enable = true;
    userEmail = "git@monoid.al";
    userName = "Ellie Hermaszewska";
    difftastic.enable = true;
    aliases = {
      po = ''
        !git push --set-upstream origin "$(git rev-parse --abbrev-ref HEAD)"'';
      s = "status -s";
      cp = "cherry-pick";
      co = "checkout";
      cob = "checkout -b";
      pr = "pull-request";
      latest = "!git log --all --oneline | head -n1 | cut -f1 -d' '";
      cpl = "!git cherry-pick $(git latest)";
      pf = "push --force-with-lease";
      authors = ''
        !f(){
          set -o pipefail;
          git blame $1 --line-porcelain |
            grep 'author ' |
            grep -v 'Not Committed Yet' |
            sed 's/author //' |
            sort |
            uniq -c |
            sort -n
        };
        f
      '';
      author =
        "!f(){ set -o pipefail; git blame $1 --line-porcelain | grep 'author ' | grep -v 'Not Committed Yet' | sed 's/author //' | sort | uniq -c | sort -nr | head -n1 | sed 's/ *[0-9]* *//' ; }; f";
      cane = "commit --amend --no-edit";
      delete-squashed = ''
        !f() {
          set -e
          local targetBranch=''${1:-master}
          git checkout -q $targetBranch
          git branch --merged | grep -v "\+" | grep -v "\*" | while read branch; do
            git branch -d "$branch" || echo "Didn't delete regular merged branch: $branch"
          done

          git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do
            mergeBase=$(git merge-base $targetBranch $branch)
            [[ $(git cherry $targetBranch $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _)) == "-"* ]] &&
              (git branch -D $branch || echo "Didn't delete squash merged branch: $branch")
          done;
        };
        f
      '';
    };
    signing = {
      signByDefault = true;
      key = builtins.readFile /home/e/.ssh/id_ed25519.pub;
    };
    includes = [{
      contents = { user.email = "ellieh@nvidia.com"; };
      condition = "gitdir:~/work";
    }];
    ignores = [ ".envrc" ".direnv" ".cache" ];
    extraConfig = rec {
      hub.protocol = "ssh";
      gpg.format = "ssh";
      init.defaultBranch = "main";
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
