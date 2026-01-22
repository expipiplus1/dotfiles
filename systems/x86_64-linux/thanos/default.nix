{ lib, pkgs, config, ... }:

{
  imports = [ ./hardware ];

  networking.hostName = "thanos";

  # Modules
  ellie.nginx-server.enable = true;
  ellie.fail2ban.enable = true;
  ellie.restic-server.enable = true;
  ellie.samba.enable = true;
  ellie.jellyfin.enable = true;
  ellie.minio.enable = true;
  ellie.home-assistant.enable = true;

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

  # Nginx virtual hosts
  services.nginx.virtualHosts = {
    "home.monoid.al" = {
      forceSSL = true;
      enableACME = true;
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
        "/film" = {
          root = "/data/share/linux-isos/files/transmission/Downloads";
          extraConfig = ''
            index index.html;
            autoindex on;
          '';
        };
      };
    };
    "restic.thanos" = {
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
      enableACME = true;
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
      enableACME = true;
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
      enableACME = true;
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
    comment = "Thanos share";
    "guest ok" = "yes";
    writable = "yes";
    "force user" = "root";
    "create mask" = "0644";
    "directory mask" = "0755";
  };

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
    "orion:s0C06f1M46DCpHUUP2r8iIrhfytkCbXWltMeMMa4jbw=%"
    "expipiplus1/update-nix-fetchgit:Z33K0KEImsos+kVTFvZxfLxaBi+D1jEeB6cX0uCo7B0="
    "light-hope:xkiDuhgkaC8uE9r3/Rr1R1QFozkqxP///eb+cdMFByA="
  ];

  system.autoUpgrade = {
    enable = true;
    randomizedDelaySec = "45min";
  };

  system.stateVersion = "20.09";
}
