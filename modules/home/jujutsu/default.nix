{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "jujutsu" {
  home.packages = with pkgs; [ jujutsu lazyjj ];
  programs.zsh = {
    shellAliases = {
      js = "jj st";
      jd = "jj diff";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Ellie Hermaszewska";
        email = "git@monoid.al";
      };
      signing = {
        sign-all = true;
        backend = "ssh";
        key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };
      ui = {
        # Use Difftastic by default
        diff.tool =
          [ "${pkgs.difftastic}/bin/difft" "--color=always" "$left" "$right" ];
        diff-editor = [ "nvim" "-c" "DiffEditor $left $right $output" ];
        paginate = "auto";
      };
    };

    # userEmail = "git@monoid.al";
    # userName = "Ellie Hermaszewska";
    # difftastic.enable = true;
    # aliases = {
    #   po = ''
    #     !git push --set-upstream origin "$(git rev-parse --abbrev-ref HEAD)"'';
    #   s = "status -s";
    #   cp = "cherry-pick";
    #   co = "checkout";
    #   cob = "checkout -b";
    #   pr = "pull-request";
    #   latest = "!git log --all --oneline | head -n1 | cut -f1 -d' '";
    #   cpl = "!git cherry-pick $(git latest)";
    #   pf = "push --force-with-lease";
    #   debase = "rebase";
    #   authors = ''
    #     !f(){
    #       set -o pipefail;
    #       git blame $1 --line-porcelain |
    #         grep 'author ' |
    #         grep -v 'Not Committed Yet' |
    #         sed 's/author //' |
    #         sort |
    #         uniq -c |
    #         sort -n
    #     };
    #     f
    #   '';
    #   author =
    #     "!f(){ set -o pipefail; git blame $1 --line-porcelain | grep 'author ' | grep -v 'Not Committed Yet' | sed 's/author //' | sort | uniq -c | sort -nr | head -n1 | sed 's/ *[0-9]* *//' ; }; f";
    #   cane = "commit --amend --no-edit";
    #   delete-squashed = ''
    #     !f() {
    #       set -e
    #       local targetBranch=''${1:-master}
    #       git checkout -q $targetBranch
    #       git branch --merged | grep -v "\+" | grep -v "\*" | while read branch; do
    #         git branch -d "$branch" || echo "Didn't delete regular merged branch: $branch"
    #       done
    #
    #       git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do
    #         mergeBase=$(git merge-base $targetBranch $branch)
    #         [[ $(git cherry $targetBranch $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _)) == "-"* ]] &&
    #           (git branch -D $branch || echo "Didn't delete squash merged branch: $branch")
    #       done;
    #     };
    #     f
    #   '';
    # };
    # includes = [{
    #   contents = { user.email = "ellieh@nvidia.com"; };
    #   condition = "gitdir:~/work/";
    # }];
    # ignores = [ ".envrc" ".direnv" ".cache" ];
    # extraConfig = rec {
    #   hub.protocol = "ssh";
    #   commit.gpgsign = true;
    #   gpg.format = "ssh";
    #   user.signingkey = "~/.ssh/id_ed25519.pub";
    #   init.defaultBranch = "main";
    #   oh-my-zsh = { only-branch = 1; };
    #   pull = { rebase = true; };
    #   rebase = {
    #     instructionFormat = "[%an] %s";
    #     autoStash = true;
    #   };
    #   github = { user = "expipiplus1"; };
    #   "credential \"https://github.com\"".username = github.user;
    #   mergetool = { keepBackup = false; };
    #   merge = { tool = "vimdiff"; };
    #   core = { editor = "vim"; };
    #   push = { default = "simple"; };
    #   color = { ui = "auto"; };
    #   sendemail = {
    #     # smtpuser = "ellie@monoid.al";
    #     smtpserver = "smtp.migadu.com";
    #     smtpencryption = "ssl"; # Not sure why tls doesn't work here..
    #     smtpserverport = 465;
    #   };
    # };
  };
}
