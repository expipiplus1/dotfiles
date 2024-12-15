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
        pager = "${pkgs.delta}/bin/delta";
        diff.format = "git";
      };
      fix.tools.clang-format = {
        command = [
          "clang-format"
          "--assume-filename=$path"
          "--style=file:/home/e/work/slang/.clang-format"
        ];
        patterns = [
          "glob:'tools/**/*.cpp'"
          "glob:'tools/**/*.h'"
          "glob:'source/**/*.cpp'"
          "glob:'source/**/*.h'"
          "glob:'examples/**/*.cpp'"
          "glob:'examples/**/*.h'"
          "glob:'prelude/**/*.cpp'"
          "glob:'prelude/**/*.h'"
          "glob:'tests/**/*.cpp'"
          "glob:'tests/**/*.h'"
        ];
      };

    };
  };
}
