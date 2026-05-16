{ ... }:

{
  networking.hostName = "haku";
  imports = [ ./hardware ./impermanence.nix ];

  # Modules
  ellie.oci.enable = true;
  ellie.fail2ban.enable = true;
  ellie.users.enable = true;
  ellie.health = {
    enable = true;
    ntfyTopicFile = "/etc/secrets/ntfy_topic";
    ntfyTokenFile = "/etc/secrets/ntfy_token";
    diskCheck.paths = [ "/" ];
    loginNotify.ignoredCIDRs = [ "e@202.83.104.81/32" ];
  };

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
  ellie.low-disk-space.enable = true;
  nix.settings.trusted-public-keys = [
    "orion:s0C06f1M46DCpHUUP2r8iIrhfytkCbXWltMeMMa4jbw="
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "light-hope:xkiDuhgkaC8uE9r3/Rr1R1QFozkqxP///eb+cdMFByA="
  ];

  zramSwap.enable = true;

  swapDevices = [{
    device = "/var/swapfile";
    size = 4 * 1024; # 4GB
  }];

  ellie.background-builder = {
    enable = true;
    flakeURL = "https://github.com/expipiplus1/dotfiles";
    ntfyTopicFile = "/etc/secrets/ntfy_topic";
    ntfyTokenFile = "/etc/secrets/ntfy_token";
    overrideInputs = [ "japan-transfer" "kanji-explorer" "anki-progress" "ug-proxy" "stickers" "wordle" ];
    packages = [
      "nixosConfigurations.light-hope.config.ellie.fonts.iosevka-term"
      "nixosConfigurations.light-hope.config.ellie.fonts.iosevka-aile"
      "nixosConfigurations.light-hope.config.ellie.fonts.iosevka-etoile"
    ];
  };

  system.stateVersion = "25.11";
}
