{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "wsl" {
  programs.zsh.shellAliases = {
    git = lib.mkForce "${
        pkgs.writeShellScriptBin "git-or-git-exe" ''
          if pwd | grep -q "/mnt/[a-z]"; then
              exec git.exe "$@"
          else
              exec ${pkgs.gitAndTools.hub}/bin/hub "$@"
          fi
        ''
      }/bin/git-or-git-exe";
  };
}
