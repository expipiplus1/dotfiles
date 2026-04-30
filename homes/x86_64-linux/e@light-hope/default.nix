{ pkgs, ... }: {
  ellie.autostart.enable = true;
  ellie.dual-boot.enable = true;
  ellie.pc.enable = true;
  ellie.sensors.enable = true;
  ellie.common.enable = true;

  services.anki-progress-sync = {
    enable = true;
    remoteHost = "e@bow";
    time = "23:59";
  };
}
