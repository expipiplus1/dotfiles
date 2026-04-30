{ config, pkgs, lib, ... }:

{
  networking.hostName = "haku";
  imports = [ ./hardware ./impermanence.nix ];

  # Modules
  ellie.oci.enable = true;
  ellie.fail2ban.enable = true;
  ellie.users.enable = true;

  # Networking
  networking.firewall.enable = true;
  time.timeZone = "Asia/Singapore";

  # SSH
  services.openssh = {
    enable = true;
    ports = [ 49813 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      MaxAuthTries = 2;
      LoginGraceTime = "30s";
    };
  };

  programs.mosh.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=256M
  '';

  # Nix
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';
  nix.settings.trusted-public-keys = [
    "orion:s0C06f1M46DCpHUUP2r8iIrhfytkCbXWltMeMMa4jbw="
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "light-hope:xkiDuhgkaC8uE9r3/Rr1R1QFozkqxP///eb+cdMFByA="
  ];

  zramSwap.enable = true;

  system.stateVersion = "25.11";
}
