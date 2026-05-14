{ lib, pkgs, config, inputs, ... }:

let
  pkgs-unstable =
    import inputs.nixpkgs-unstable { localSystem = "x86_64-linux"; };
  convertPage = pkgs.runCommand "convert-page" { } ''
    mkdir -p $out
    cp ${./convert.html} $out/index.html
  '';
in {
  imports = [ ./hardware ];

  networking.hostName = "bow";

  # Modules
  ellie.nginx-server.enable = true;
  ellie.fail2ban.enable = true;
  ellie.restic-server.enable = true;
  ellie.samba.enable = true;
  ellie.jellyfin.enable = true;
  ellie.home-assistant.enable = true;
  ellie.immich.enable = false;
  ellie.health = {
    enable = true;
    ntfyTopicFile = "/etc/secrets/ntfy_topic";
    ntfyTokenFile = "/etc/secrets/ntfy_token";
    loginNotify.ignoredCIDRs = [ "e@192.168.1.0/24" ];
    diskCheck.paths = [ "/" "/data" ];
    btrfsCheck = {
      enable = true;
      devices = [ "/" "/data" ];
    };
    healthEndpoint = "health.home.monoid.al";
    deadManSwitch = {
      enable = true;
      peerName = "sen";
      peerUrl = "https://health.monoid.al";
    };
  };
  ellie.dns = {
    enable = true;
    trustedCIDRs = [
      "192.168.1.0/24" # LAN
      "202.83.104.81/32" # home WAN
      "172.104.175.207/32" # sen public
    ];
    peerHost = "sen.monoid.al";
    peerIP = "172.104.175.207";
    localHosts = [
      "192.168.1.148 bow"
      "192.168.1.148 pihole.bow"
      "192.168.1.148 restic.bow"
      "192.168.1.148 ultimate-guitar.com"
      "192.168.1.148 www.ultimate-guitar.com"
      "192.168.1.148 tabs.ultimate-guitar.com"
      "192.168.1.148 static.ultimate-guitar.com"
    ];
    localTLD = "bow";
    webUIVHost = "pihole.bow"; # LAN-only pseudo-TLD, no HTTPS
    webUIPublic = false;
    dotVHostName = "bow.home.monoid.al";
    dnsListenAddresses = [ "127.0.0.1" "192.168.1.148" ];
  };

  services.postgresql.package = pkgs.postgresql_16;

  # Boot
  boot.loader.grub.enable = true;
  boot.loader.grub.device =
    "/dev/disk/by-path/pci-0000:00:1a.0-usb-0:1.3:1.0-scsi-0:0:0:0";

  # Services
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  # Networking
  networking.interfaces.eth0.macAddress = "5A:B5:1A:A6:79:5E";

  networking.firewall.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    allowSFTP = false;
    extraConfig = ''
      Subsystem sftp internal-sftp
      Match user sshfs-transmission
        ForceCommand internal-sftp
        ChrootDirectory /data/share/linux-isos
        AllowTcpForwarding no
        X11Forwarding no
      Match user sshfs-sen
        ForceCommand internal-sftp
        ChrootDirectory /data/sen
        AllowTcpForwarding no
        X11Forwarding no
    '';
  };

  services."japan-transfer" = {
    enable = true;
    port = 19586;
    jobs = 6;
  };

  services.kanji-explorer = {
    enable = true;
    port = 19587;
  };

  services.anki-progress = {
    enable = true;
    port = 19588;
    syncUser = "e";
  };

  services.ug-proxy = {
    enable = true;
    # 80/443 are already opened by ellie.nginx-server; LAN-only access is
    # enforced at the nginx layer below rather than the firewall.
    openFirewall = false;
    nginx = {
      enable = true;
      # Outside /var/lib/ug-proxy because that path is owned by the
      # ug-proxy DynamicUser with mode 700 — nginx can't traverse into
      # it. /var/lib/nginx-certs/ is plain root-owned 755 so nginx can
      # read the leaf files.
      sslCertificate = "/var/lib/nginx-certs/ug-proxy/server.crt";
      sslCertificateKey = "/var/lib/nginx-certs/ug-proxy/server.key";
    };
    # Public-facing read-only catalogue: search page + cached tab
    # reads at ug.home.monoid.al. Uncached /tab/<id> redirects to
    # ultimate-guitar.com. Covered by the wildcard *.home.monoid.al
    # Let's Encrypt cert provisioned in modules/nixos/nginx-server.
    publicHosts = {
      enable = true;
      hostNames = [ "ug.home.monoid.al" ];
      useACMEHost = "monoid.al";
    };
  };

  # Restrict the upstream-spoofing ug-proxy nginx vhost to LAN
  # clients (matches the restic.bow pattern). The vhost itself
  # is created by the services.ug-proxy module; this just layers
  # an allow/deny ACL onto its root location.
  services.nginx.virtualHosts."ultimate-guitar.com".locations."/".extraConfig =
    ''
      allow 192.168.1.0/24;
      allow 127.0.0.1;
      deny all;
    '';
  # Public-facing ug.home.monoid.al: world-accessible (no LAN ACL)
  # but gated by HTTP basic auth, same credentials file as
  # home.monoid.al. The proxy itself only serves the read-only
  # catalogue on this hostname so even authenticated users can't
  # trigger upstream UG fetches.
  services.nginx.virtualHosts."ug.home.monoid.al".basicAuthFile =
    "/etc/nginx/auth/home.monoid.al";

  # Nginx virtual hosts
  services.nginx.virtualHosts = {
    "home.monoid.al" = {
      forceSSL = true;
      useACMEHost = "monoid.al";
      default = true;
      basicAuthFile = "/etc/nginx/auth/home.monoid.al";
      locations = {
        "/" = {
          priority = 1001;
          root = "/var/www";
          extraConfig = ''
            index index.html;
            autoindex on;
          '';
        };
        "/convert/" = { alias = "${convertPage}/"; };
        "/film" = {
          root = "/data/share/linux-isos/files/transmission/Downloads";
          extraConfig = ''
            index index.html;
            autoindex on;
          '';
        };
        "/transfer-calculator/" = {
          proxyPass = "http://127.0.0.1:19586/";
          proxyWebsockets = true;
        };
        "/kanji/" = {
          proxyPass = "http://127.0.0.1:19587/";
          proxyWebsockets = true;
        };
        "/anki/" = {
          proxyPass = "http://127.0.0.1:19588/";
          proxyWebsockets = true;
        };
      };
    };
    "restic.bow" = {
      locations."/" = {
        proxyPass = "http://localhost:8000";
        extraConfig = ''
          allow 192.168.1.0/24;
          allow 127.0.0.1;
          deny all;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          client_max_body_size 0;
        '';
      };
    };
    "restic.home.monoid.al" = {
      forceSSL = true;
      useACMEHost = "monoid.al";
      extraConfig = ''
        ignore_invalid_headers off;
        client_max_body_size 0;
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://localhost:8000";
        extraConfig = ''
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        '';
      };
    };
    "jellyfin.home.monoid.al" = {
      useACMEHost = "monoid.al";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_buffering off;
          client_max_body_size 20G;
          proxy_connect_timeout 600;
          proxy_send_timeout 600;
          proxy_read_timeout 600;
          send_timeout 600;
        '';
      };
    };
    "ass.home.monoid.al" = {
      forceSSL = true;
      useACMEHost = "monoid.al";
      extraConfig = "proxy_buffering off;";
      locations."/" = {
        proxyPass = "http://[::1]:8123";
        proxyWebsockets = true;
      };
    };
  };

  # Samba share
  services.samba.settings.share = {
    path = "/data/share";
    browseable = "yes";
    comment = "Bow share";
    "guest ok" = "yes";
    writable = "yes";
    "force user" = "root";
    "create mask" = "0644";
    "directory mask" = "0755";
  };

  # Use newer Home Assistant from nixpkgs-unstable
  services.home-assistant.package = pkgs-unstable.home-assistant;

  # Home assistant SmartIR with custom aircon codes
  services.home-assistant.customComponents = [
    (pkgs-unstable.home-assistant-custom-components.smartir.overrideAttrs
      (old: {
        postInstall = (old.postInstall or "") + ''
          cp ${
            ./aircon-codes
          }/*.json $out/custom_components/smartir/codes/climate/
        '';
      }))
  ];

  # Home assistant climate config
  services.home-assistant.config = {
    cors_allowed_origins = [ "https://keitetran.github.io" ];
    climate = [
      {
        platform = "smartir";
        name = "living room ac";
        unique_id = "lr_ac";
        device_code = 1114;
        controller_data = "remote.living_room_ir";
      }
      {
        platform = "smartir";
        name = "hall ac";
        unique_id = "hall_ac";
        device_code = 1114;
        controller_data = "remote.hall_ir";
      }
      {
        platform = "smartir";
        name = "bedroom ac";
        unique_id = "bedroom_ac";
        device_code = 1119;
        controller_data = "remote.bedroom_ir";
      }
      {
        platform = "smartir";
        name = "study ac";
        unique_id = "study_ac";
        device_code = 1692;
        controller_data = "remote.study_ir";
      }
    ];
  };

  # Misc
  time.timeZone = "Asia/Singapore";

  environment.systemPackages = with pkgs; [
    file
    git
    htop
    silver-searcher
    tmux
    vim
    gcc
    lm_sensors
    hddtemp
    restic
  ];

  # Users
  ellie.users.enable = true;
  security.sudo.enable = true;
  users.mutableUsers = false;

  users.users.sshfs-transmission = {
    isSystemUser = true;
    group = "sshfs-transmission";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAItBGJ1aQHMgLYWBZz0OH8Vrfyd6q4oSSjlbtfQ+doD sshfs-transmission-sen@monoid.al"
    ];
  };
  users.groups.sshfs-transmission = { };

  users.users.sshfs-sen = {
    isSystemUser = true;
    group = "sshfs-sen";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIlV9/maL1JHVnBr+rhG2GWn1LK8XV3jPveocgtgFQWz sshfs-sen@monoid.al"
    ];
  };
  users.groups.sshfs-sen = { };

  # Nix
  nix.settings.trusted-users = [ "root" "@wheel" "nix" ];
  nix.settings.substituters = [ "https://cache.nixos.org/" ];
  nix.settings.trusted-public-keys = [
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "orion:s0C06f1M46DCpHUUP2r8iIrhfytkCbXWltMeMMa4jbw="
    "light-hope:xkiDuhgkaC8uE9r3/Rr1R1QFozkqxP///eb+cdMFByA="
  ];

  system.autoUpgrade = {
    enable = true;
    randomizedDelaySec = "45min";
  };

  system.stateVersion = "20.09";
}
