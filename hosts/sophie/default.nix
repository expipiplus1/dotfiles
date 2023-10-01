{ config, pkgs, ... }:

{
  imports = [
    ../shared/docker.nix
    ../shared/nix.nix
    ../shared/ssh.nix
    ../shared/udev.nix
    ../shared/users.nix
    ../shared/nvidia.nix
    ./darlings.nix
    ./dm.nix
    ./hardware
    ./networking.nix
    # ./sophie/tailscale.nix
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  #
  # Misc things, too small for their own module
  #
  services.earlyoom = { enable = true; };

  environment.systemPackages = with pkgs; [ lm_sensors ntfs3g ];

  programs.steam.enable = true;

  environment.wordlist.enable = true;

  nix.settings.system-features = [ "gccarch-znver3" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
