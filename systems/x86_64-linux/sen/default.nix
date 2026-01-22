{ config, pkgs, lib, ... }:

let
  sshfsAutoMount = { user, host, port ? null, remoteDir, mountPoint, identityFile, uid ? null }:
    {
      device = "${user}@${host}:${remoteDir}";
      inherit mountPoint;
      fsType = "sshfs";
      neededForBoot = false;
      options = [
        "allow_other"
        "_netdev"
        "x-systemd.automount"
        "IdentityFile=${identityFile}"
        "ServerAliveInterval=15"
        "reconnect"
        (builtins.replaceStrings [ " " ] [ "\\040" ]
          "ssh_command=${pkgs.openssh}/bin/ssh")
      ] ++ lib.optional (uid != null) "uid=${builtins.toString uid}"
        ++ lib.optional (port != null) "PORT=${builtins.toString port}";
    };
in {
  imports = [ ./hardware ];

  networking.hostName = "sen";

  # Modules
  ellie.nginx-server.enable = true;
  ellie.fail2ban.enable = true;

  # Boot (Linode specific)
  boot.loader.grub.enable = true;
  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;
  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 1048576;
  };

  # Networking
  networking.usePredictableInterfaceNames = false;
  networking.firewall.allowedTCPPorts = [ 3000 5000 8080 8042 ];

  time.timeZone = "Asia/Singapore";

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
  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
  };

  services.logrotate = {
    enable = true;
    settings.nginx = {
      enable = true;
      files = "/var/log/nginx/*.log";
      rotate = 2;
      frequency = "daily";
      su = "${config.services.nginx.user} ${config.services.nginx.group}";
    };
  };

  # Transmission
  services.transmission = {
    enable = true;
    settings = {
      download-dir = "/mnt/thanos-transmission/transmission/Downloads";
      incomplete-dir = "/mnt/thanos-transmission/transmission/.incomplete";
      rpc-host-whitelist = "transmission.monoid.al";
    };
  };

  services.nginx.virtualHosts."transmission.monoid.al" = {
    forceSSL = true;
    enableACME = true;
    basicAuthFile = "/etc/nginx/auth/transmission.monoid.al";
    extraConfig = ''
      client_max_body_size 128M;
    '';
    locations."/" = {
      proxyPass = "http://localhost:9091";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };

  # PostgreSQL backup
  services.postgresql.package = pkgs.postgresql_13;
  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "/mnt/thanos-backup/psql";
  };

  # Restic backups
  services.restic.backups.configuration = {
    user = "root";
    passwordFile = "/etc/secrets/synapse-restic-password";
    paths = [ "/etc/nixos/" ];
    repositoryFile = "/etc/secrets/restic-repository";
    timerConfig = {
      OnCalendar = "01:15";
      RandomizedDelaySec = "5h";
    };
  };

  # SSHFS mount to thanos
  system.fsPackages = [ pkgs.sshfs ];
  fileSystems.sshfs-transmission = sshfsAutoMount {
    user = "sshfs-transmission";
    host = "home.monoid.al";
    port = 2222;
    remoteDir = "/files";
    mountPoint = "/mnt/thanos-transmission";
    identityFile = "/etc/secrets/sshfs-transmission-sen";
    uid = config.users.users.transmission.uid;
  };

  # Users
  users.extraUsers.e = {
    isNormalUser = true;
    uid = 1000;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "transmission" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFErWB61gZadEEFteZYWZm8QRwabpl4kDHXsm0/rsLqoyWJN5Y4zF4kowSGyf92LfJu9zNBs2viuT3vmsLfg6r4wkbVyujpEo3JLuV79r9K8LcM32wA52MvQYATEzxuamZPZCBT9fI/2M6bC9lz67RQ5IoENfjZVCstOegSmODmOvGUs6JjrB40slB+4YXCVFypYq3uTyejaBMtKdu1S4TWUP8WRy8cWYmCt1+a6ACV2yJcwnhSoU2+QKt14R4XZ4QBSk4hFgiw64Bb3WVQlfQjz3qA4j5Tc8P3PESKJcKW/+AsavN1I2FzdiX1CGo2OL7p9TcZjftoi5gpbmzRX05 j@riza"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBML4JuxphjzZ/gKVLRAunKfTuFT6VVr6DfXduvsiHz j@orion"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGieLCIaLlzqPSZpa8e1SIHm9DVb97SKzzfg6mwvQdz4 e@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8wDcEeHIfK63eMWC3pXRmX1DpItY3+cpS0C2fmYc31 e@light-hope"
    ];
  };

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
  ];

  system.stateVersion = "20.09";
}
