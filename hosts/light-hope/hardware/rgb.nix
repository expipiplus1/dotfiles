{ config, lib, pkgs, modulesPath, ... }:

{
  services.hardware.lian-li-pump-control = {
    enable = true;
    speed = "pwm";
    color = "sync";
  };

  services.udev.packages = [ pkgs.openrgb ];
  systemd.services.openrgb-oneshot = {
    description = "OpenRGB oneshot";
    wantedBy = [
      "multi-user.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    serviceConfig = {
      StateDirectory = "OpenRGB";
      WorkingDirectory = "/var/lib/OpenRGB";
      ExecStart = "${pkgs.openrgb}/bin/openrgb --profile ${./gay.orp}";
      Type = "oneshot";
    };
  };
}
