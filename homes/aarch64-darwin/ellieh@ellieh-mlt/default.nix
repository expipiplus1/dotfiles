{ pkgs, lib, ... }:
{
  ellie.common.enable = true;
  home.username = lib.mkForce "ellieh";
  home.homeDirectory = lib.mkForce "/Users/ellieh";
}
