{ ... }:
let
  rootd = d: m: {
    directory = d;
    user = "root";
    group = "root";
    mode = m;
  };

in {
  users.mutableUsers = false;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      (rootd "/var/lib/nixos" "0755")
      (rootd "/var/lib/systemd" "0755")
      (rootd "/var/lib/fail2ban" "0755")
      (rootd "/var/log" "0755")
      {
        directory = "/var/lib/background-builder";
        user = "e";
        group = "users";
        mode = "0755";
      }
    ];
    # No files entries: without wipe-on-boot these persist naturally
    # on the ext4 root. Bind-mounting over existing files fails.
  };

  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
}
