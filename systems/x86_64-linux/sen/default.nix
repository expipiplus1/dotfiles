{ config, pkgs, lib, ... }:

{
  networking.hostName = "sen";

  # Modules
  ellie.linode.enable = true;
  ellie.nginx-server.enable = true;
  ellie.fail2ban.enable = true;
  ellie.logrotate-nginx.enable = true;
  ellie.transmission.enable = true;
  ellie.dns = {
    enable = true;
    trustedCIDRs = [
      "192.168.1.0/24"     # LAN (no-op on sen, kept for consistency)
      "202.83.104.81/32"   # home WAN
      "172.104.175.207/32" # sen public (loopback to self)
    ];
    peerHost = "thanos.home.monoid.al";
    peerIP = "202.83.104.81";
    webUIVHost = "pihole.monoid.al";
    webUIPublic = true;
    webUIBasicAuthFile = "/etc/nginx/auth/transmission.monoid.al";
    dotVHostName = "sen.monoid.al";
    dnsListenAddresses = [ "127.0.0.1" "172.104.175.207" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3604511d-9883-4045-9f7e-bb49ed1be42c";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/8af325d4-31b1-4274-a57c-72d708589360"; }
    { device = "/swapfile"; }
  ];

  # Networking
  networking.usePredictableInterfaceNames = false;
  networking.firewall.enable = true;

  time.timeZone = "Asia/Singapore";

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 1048576;
  };

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "65536";
  }];

  services.journald.extraConfig = ''
    SystemMaxUse=512M
  '';

  programs.mosh.enable = true;

  services.openssh = {
    enable = true;
    # Non-default port to drop ~99% of scanner noise. Make sure to
    # update ~/.ssh/config and any deploy/CI tooling.
    ports = [ 50539 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # MaxAuthTries=2 gives a one-typo grace per connection without
      # letting a scanner burn 6 password attempts per TCP connection.
      # Combined with PasswordAuthentication=false above, this only
      # affects key-auth: ssh will try identities in order and
      # disconnect after 2 wrong keys. If ssh-agent has many identities
      # loaded, set IdentitiesOnly=yes in ~/.ssh/config for sen.
      MaxAuthTries = 2;
      LoginGraceTime = "30s";
    };
  };

  # Users
  ellie.users.enable = true;
  users.users.e.extraGroups = lib.mkAfter [ "transmission" ];

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

  system.stateVersion = "20.09";
}
