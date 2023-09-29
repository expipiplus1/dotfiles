{ config, pkgs, ... }:

{
  imports = [
    ../shared/nix.nix
    ../shared/ssh.nix
    ../shared/udev.nix
    ../shared/users.nix
    ../shared/dm.nix
    ./impermanence.nix
    ./hardware
    ./networking.nix
  ];

  #
  # Misc things, too small for their own module
  #
  time.timeZone = "Asia/Singapore";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.systemPackages = with pkgs; [ git vim ];

  programs.steam.enable = true;

  environment.wordlist.enable = true;

  services.nixseparatedebuginfod.enable = true;
}
