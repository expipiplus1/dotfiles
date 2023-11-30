{ config, pkgs, ... }:

{
  imports = [
    ../shared/nix.nix
    ../shared/ssh.nix
    ../shared/udev.nix
    ../shared/users.nix
    ../shared/misc.nix
    ../shared/docker.nix
    ./dm.nix
    ./impermanence.nix
    ./hardware
    ./networking.nix
    ../shared/vm.nix
    ../shared/input.nix
  ];

  vm.enable = true;
  vm.users = [ "e" ];

  #
  # Misc things, too small for their own module
  #

  environment.wordlist.enable = true;

  programs.steam.enable = true;

  services.nixseparatedebuginfod.enable = true;

  nix.settings.system-features = [ "gccarch-znver4" ];

  # To not upset Windows
  time.hardwareClockInLocalTime = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}
