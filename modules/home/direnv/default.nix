{ lib, ... }@inputs:
lib.internal.simpleModule inputs "direnv" {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # silent  = true;
    config = { global.hide_env_diff = true; };
  };
}
