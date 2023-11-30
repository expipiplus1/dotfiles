{ lib, ... }@inputs:
lib.internal.simpleModule inputs "direnv" {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh.initExtra = ''
    export DIRENV_LOG_FORMAT=$(printf "\e[1;30""mdirenv: %%s\e[0")
  '';
}
