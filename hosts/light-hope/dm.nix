{ config, pkgs, ... }: {
  imports = [ ../shared/dm.nix ];
  hardware.opengl.extraPackages = with pkgs; [ amdvlk ];
}
