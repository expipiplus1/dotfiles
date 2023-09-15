{ config, pkgs, ... }:

{
  imports = [
    ./hardware
    ./afp.nix
    # ./minio.nix
    ./quoth.nix
    ./report.nix
    ./home-assistant.nix
    ./tailscale.nix
  ];

  ########################################
  # Boot
  ########################################

  boot.loader.grub.enable = true;
  # sd card
  # boot.loader.grub.device = "/dev/disk/by-id/usb-HP_iLO_Internal_SD-CARD_000002660A01-0:0";
  boot.loader.grub.device =
    "/dev/disk/by-path/pci-0000:00:1a.0-usb-0:1.3:1.0-scsi-0:0:0:0";
  # boot.loader.grub.memtest86.enable = true;

  ########################################
  # Services
  ########################################

  services.slimserver = { enable = false; };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  ########################################
  # Networking
  ########################################

  networking.hostName = "historian-bow";
  networking.interfaces.eth0 = { macAddress = "5A:B5:1A:A6:79:5E"; };
  # networking.dhcpcd.extraConfig = ''
  #   # define static profile
  #   profile static_eth0
  #   static ip_address=192.168.1.19/24
  #   static routers=192.168.1.1
  #   static domain_name_servers=192.168.1.148 192.168.1.20
  #
  #   # fallback to static profile on eth0
  #   interface eth0
  #   fallback static_eth0
  # '';

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # DNS
      53
      # HTTP(S)
      80
      443
      # Slimserver
      # Samba
      139
      445
      # Socks
      12345
    ];
    allowedUDPPorts = [
      # DNS
      53
      # Slimserver
      # Samba
      137
      138
      # Mosh
      60000
      60001
    ];
  };

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

  # From https://github.com/NixOS/nixpkgs/issues/61617#issuecomment-623934193
  services.dnsmasq = {
    enable = true;
    settings = {
      "domain-needed" = true;
      "bogus-priv" = true;
      "no-resolv" = true;

      "server" = [ "208.67.220.220" "8.8.4.4" ];

      "listen-address" = "0.0.0.0";
      "bind-interfaces" = true;

      "cache-size" = 10000;
      "log-queries" = true;
      "log-facility" = "/tmp/ad-block.log";
      "local-ttl" = 300;

      "no-hosts" = true;
      "conf-file" =
        "/etc/assets/hosts-blocklists/dnsmasq/dnsmasq.blacklist.txt";
      "address" = "/historian-bow/192.168.1.148";
    };
  };

  services.fail2ban = {
    enable = true;
    jails = {
      nginx-botsearch = ''
        filter   = nginx-botsearch
        action = iptables-multiport[name=NGINXBOT, port=http,https, protocol=tcp]
      '';
      nginx-http-auth = ''
        filter   = nginx-http-auth
        action = iptables-multiport[name=NGINXAUTH, port=http,https, protocol=tcp]
      '';
    };
  };

  security.acme = {
    defaults.email = "acme@sub.monoid.al";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    appendHttpConfig = ''
      server_names_hash_bucket_size 64;
    '';
    virtualHosts = {
      "restic.historian-bow" = {
        locations."/" = {
          proxyPass = "http://localhost:8000";
          extraConfig = ''
            allow 192.168.1.0/24;
            allow 127.0.0.1;
            deny all;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # Allow any size file to be uploaded.
            client_max_body_size 0;
          '';
        };
      };
      "restic.home.monoid.al" = {
        forceSSL = true;
        enableACME = true;
        extraConfig = ''
          # To allow special characters in headers
          ignore_invalid_headers off;
          # Allow any size file to be uploaded.
          client_max_body_size 0;
          # To disable buffering
          proxy_buffering off;
        '';
        locations = {
          "/" = {
            proxyPass = "http://localhost:8000";
            extraConfig = ''
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
    };
  };

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.restic.server = {
    enable = true;
    dataDir = "/data/restic";
    privateRepos = true;
    appendOnly = true;
  };
  systemd.services.restic-rest-server.after = [ "local-fs.target" ];

  services.samba = {
    enable = true;
    extraConfig = ''
      workgroup = WORKGROUP
      hosts allow = 192.168.1. localhost
      hosts deny = 0.0.0.0/0
      map to guest = Bad User
      get quota command = ${
        pkgs.writeScript "smb-quota.sh" ''
          #!${pkgs.bash}/bin/bash
          echo "0 0 0 0 0 0 0"
        ''
      }
    '';
    shares = {
      share = {
        browseable = "yes";
        comment = "Historian-Bow share";
        "guest ok" = "yes";
        path = "/data/share";
        writable = "yes";
        "force user" = "root";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  services.nullmailer = {
    enable = false;
    remotesFile = "/etc/nullmailer-credentials";
    config.defaulthost = "home.monoid.al";
  };

  ########################################
  # Misc
  ########################################

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

  ########################################
  # Users
  ########################################

  security.sudo.enable = true;

  users.mutableUsers = false;

  programs.zsh.enable = true;
  users.users.j = {
    isNormalUser = true;
    home = "/home/j";
    description = "Ellie Hermaszewska";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    hashedPassword =
      "$6$22Tois4OjFC$y3kfcuR7BBHVj8LnZNIfLyNhQOdVZkkTseXCNbiA95WS2JSXv4Zynmy8Ie9nCxNokgSL8cuO1Le0m4VHuzXXI.";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFErWB61gZadEEFteZYWZm8QRwabpl4kDHXsm0/rsLqoyWJN5Y4zF4kowSGyf92LfJu9zNBs2viuT3vmsLfg6r4wkbVyujpEo3JLuV79r9K8LcM32wA52MvQYATEzxuamZPZCBT9fI/2M6bC9lz67RQ5IoENfjZVCstOegSmODmOvGUs6JjrB40slB+4YXCVFypYq3uTyejaBMtKdu1S4TWUP8WRy8cWYmCt1+a6ACV2yJcwnhSoU2+QKt14R4XZ4QBSk4hFgiw64Bb3WVQlfQjz3qA4j5Tc8P3PESKJcKW/+AsavN1I2FzdiX1CGo2OL7p9TcZjftoi5gpbmzRX05 j@riza"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChHW69/lghzz2b6T8hj6cShYGGDNA7g+HhS+P7JAWT43NiCvM+0S3xYr0sY/MNBqTHIV/5e2prP4uaCq7uyNT/5s8LLm6at8dhrKN1RZWQpHD9FID5sgw4yv8HANyVpt1+zY6PoqmhAb+Bj/g/H3Ijb+AAWbvWKxUMoChC9nWd5G+ogPpPQmElg/aGxjAL0oSuwGHEO1wNvV4/ddKLEWiLNF8Xdc0s4QkQnJZhyZMa+oaerI4wF7GqsVzsYg4ppK6YbZt5rv41XCqKp889b2JZphRVlN7LvJxX11ttctxFvhSlqa+C/7QvoFiOo5wJxZrwH3P1rMRfIWwzYas/sWlx jophish@cardassia.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBML4JuxphjzZ/gKVLRAunKfTuFT6VVr6DfXduvsiHz j@orion"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFTU5LRUEQrVz94VSBbxFzk5AzKp1CwCVBr2tO9cIEq j@nebula"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGieLCIaLlzqPSZpa8e1SIHm9DVb97SKzzfg6mwvQdz4 e@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBAtwZjdx6Tioq3RNCMFyIyAN19MG7vUKwC7fGE8OZzn j@Dark-Bramble.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAzAS1qjFdIIYo3smCLYX8JG1Q2jrmnVjkuC3cZWwMaj JuiceSSH"
    ];
  };

  # users.users.emma = {
  #   name = "emma";
  #   group = "users";
  #   hashedPassword = "$6$R71AjWfi.7dWVvA$sSR4eJ0VBPDJ53IvEFflKue5Eitgr8DfvV05cT.3YW0177skQX/XJOT1KQAHHO8wrYh6qWNmXHQX1vI94L504.";
  # };

  users.users.sshfs-transmission = {
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAItBGJ1aQHMgLYWBZz0OH8Vrfyd6q4oSSjlbtfQ+doD sshfs-transmission-sen@monoid.al"
    ];
  };
  users.users.sshfs-sen = {
    isSystemUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIlV9/maL1JHVnBr+rhG2GWn1LK8XV3jPveocgtgFQWz sshfs-sen@monoid.al"
    ];
  };
  users.users.sshfs-sen.group = "sshfs-sen";
  users.groups.sshfs-sen = { };

  users.users.sshfs-transmission.group = "sshfs-transmission";
  users.groups.sshfs-transmission = { };

  ########################################
  # Nix
  ########################################

  nix.settings.trusted-users = [ "root" "@wheel" "nix" ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.substituters = [
    # "http://nixos-arm.dezgeg.me/channel"
    "https://cache.nixos.org/"
    # "s3://nix-cache?region=ap-southeast-1&scheme=http&endpoint=localhost:9002"
  ];
  nix.settings.trusted-public-keys = [
    # "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%"
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "orion:s0C06f1M46DCpHUUP2r8iIrhfytkCbXWltMeMMa4jbw=%"
    "expipiplus1/update-nix-fetchgit:Z33K0KEImsos+kVTFvZxfLxaBi+D1jEeB6cX0uCo7B0="
  ];
  networking.hosts = {
    "192.168.1.77" = [ "riza" ];
    "192.168.1.121" = [ "orion" ];
    "192.168.1.20" = [ "nebula" ];
    "192.168.1.104" = [ "gamora" ];
  };
  # nix.buildMachines = [ {
  #   hostName = "riza";
  #   system = "x86_64-linux";
  #   maxJobs = 8;
  #   speedFactor = 2;
  #   supportedFeatures = ["big-parallel"]; # To get it to build linux
  #   mandatoryFeatures = [];
  # }
  # {
  #   hostName = "orion";
  #   sshUser = "nix";
  #   sshKey = "/root/.ssh/id_buildfarm";
  #   system = "x86_64-linux";
  #   maxJobs = 16;
  #   speedFactor = 4;
  #   supportedFeatures = ["big-parallel"]; # To get it to build linux
  #   mandatoryFeatures = [];
  # }];
  # nix.distributedBuilds = true;

  nixpkgs.overlays = [
    (self: super: {
      memtest86plus = self.callPackage ({ stdenv, fetchurl, lib }:
        stdenv.mkDerivation rec {
          pname = "memtest86+";
          version = "5.31b";

          src = fetchurl {
            url =
              "https://www.memtest.org/download/${version}/memtest86+-${version}.tar.gz";
            sha256 = "028zrch87ggajlb5xx1c2ab85ggl9qldpibf45735sy0haqzyiki";
          };

          hardeningDisable = [ "all" ];

          doCheck = stdenv.isi686;
          checkTarget = "run_self_test";

          installPhase = ''
            install -Dm0444 -t $out/ memtest.bin
          '';

          meta = with lib; {
            homepage = "https://www.memtest.org/";
            description = "An advanced memory diagnostic tool";
            license = licenses.gpl2Only;
            platforms = [ "x86_64-linux" "i686-linux" ];
            maintainers = with maintainers; [ evils ];
          };
        }) { };
    })
  ];

  services.nix-serve = {
    enable = false;
    secretKeyFile = "/var/cache-priv-key.pem";
  };

  system.autoUpgrade = {
    enable = true;
    randomizedDelaySec = "45min";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
