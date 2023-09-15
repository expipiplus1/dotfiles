# From https://jarmac.org/posts/time-machine.html
#
{ config, pkgs, ... }:
let
  timeMachineDir = "/data/share/Emma";
  user = "emma";
in {
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  # Samba was more reliable
  services.netatalk = {
    enable = false;

    settings = {
      "mimic model" = "TimeCapsule6,106";
      "log level" = "default:warn";
      "log file" = "/var/log/afpd.log";
      "hosts allow" = "192.168.1.0/24";
      "set password" = "yes";
      "${user}'s share" = {
        "path" = timeMachineDir;
        "valid users" = user;
      };
      "linux isos" = {
        "path" = "/data/share/linux-isos";
        "valid users" = user;
        "read only" = "yes";
      };
      "music" = {
        "path" = "/data/music";
        "valid users" = user;
        "read only" = "yes";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 548 636 ];
}
