{ lib, pkgs, config, ... }@inputs:
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
in
lib.internal.simpleModule inputs "transmission" {
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
}
