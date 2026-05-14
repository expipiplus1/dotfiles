{ config, pkgs, lib, ... }:

{
  networking.hostName = "sen";

  # Modules
  ellie.linode.enable = true;
  ellie.nginx-server.enable = true;
  ellie.fail2ban.enable = true;
  ellie.logrotate-nginx.enable = true;
  ellie.transmission.enable = true;
  ellie.health = {
    enable = true;
    ntfyTopicFile = "/etc/secrets/ntfy_topic";
    ntfyTokenFile = "/etc/secrets/ntfy_token";
    loginNotify.ignoredCIDRs = [ "e@202.83.104.81/32" ];
    healthEndpoint = "health.monoid.al";
    deadManSwitch = {
      enable = true;
      peerName = "bow";
      peerUrl = "https://health.home.monoid.al";
    };
  };
  ellie.dns = {
    enable = true;
    trustedCIDRs = [
      "192.168.1.0/24" # LAN (no-op on sen, kept for consistency)
      "202.83.104.81/32" # home WAN
      "172.104.175.207/32" # sen public (loopback to self)
    ];
    peerHost = "bow.home.monoid.al";
    peerIP = "202.83.104.81";
    localHosts = [
      "192.168.1.148 ultimate-guitar.com"
      "192.168.1.148 www.ultimate-guitar.com"
      "192.168.1.148 tabs.ultimate-guitar.com"
      "192.168.1.148 static.ultimate-guitar.com"
    ];
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

  # Redirect ug.monoid.al → ug.home.monoid.al (the actual ug-proxy
  # public vhost, which lives on bow and is gated by basic auth).
  # Lets users / bookmarks use the shorter monoid.al name without
  # having to expose ug-proxy on sen itself.
  services.nginx.virtualHosts."ug.monoid.al" = {
    forceSSL = true;
    useACMEHost = "monoid.al";
    globalRedirect = "ug.home.monoid.al";
  };

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
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 1d";
  };
  nix.extraOptions = ''
    min-free = ${toString (512 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';
  nix.settings.trusted-public-keys = [
    "orion:s0C06f1M46DCpHUUP2r8iIrhfytkCbXWltMeMMa4jbw="
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "light-hope:xkiDuhgkaC8uE9r3/Rr1R1QFozkqxP///eb+cdMFByA="
  ];

  system.stateVersion = "20.09";
}
