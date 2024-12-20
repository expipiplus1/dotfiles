{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "dm" {
  ellie.fonts.enable = true;

  # Some of these might be useful in getting wayland working
  # hardware.nvidia.powerManagement.enable = false;
  # hardware.opengl.enable = true;
  # hardware.opengl.driSupport32Bit = true;
  security.polkit.enable = true;
  # services.xserver.displayManager.gdm.wayland = true;

  services.xserver = { enable = true; };

  console.useXkbConfig = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Firefox nonsense
  environment.sessionVariables.TZ = "${config.time.timeZone}";

  services.ddccontrol.enable = true;
}
