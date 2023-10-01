{ config, pkgs, ... }:

{
  imports = [
    ../shared/nix.nix
    ../shared/ssh.nix
    ../shared/udev.nix
    ../shared/users.nix
    ../shared/dm.nix
    ../shared/misc.nix
    ./impermanence.nix
    ./hardware
    ./networking.nix
  ];

  #
  # Misc things, too small for their own module
  #

  programs.steam.enable = true;

  services.nixseparatedebuginfod.enable = true;

  nix.settings.system-features = [ "gccarch-znver4" ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
