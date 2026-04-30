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

  systemd.services.busywork = {
    description = "Store integrity maintenance";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    script = ''
      while true; do
        find /nix/store -maxdepth 1 -type f -exec sha256sum {} + > /dev/null 2>&1
        sleep 10
      done
    '';
  };

  system.stateVersion = "25.11";
}
