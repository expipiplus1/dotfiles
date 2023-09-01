{ config, pkgs, ... }:

{
  imports = [
    ../shared/docker.nix
    ../shared/nix.nix
    ../shared/ssh.nix
    ../shared/udev.nix
    ../shared/users.nix
    ./darlings.nix
    ./dm.nix
    ./hardware
    ./networking.nix
    # ./sophie/tailscale.nix
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  time.timeZone = "Asia/Singapore";

  #
  # Misc things
  #
  services.earlyoom = { enable = true; };

  environment.systemPackages = with pkgs; [ git vim lm_sensors ntfs3g ];

  programs.steam.enable = true;

  environment.wordlist.enable = true;
}

