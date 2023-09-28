{ config, pkgs, ... }:

{
  imports = [ ./dm/fonts.nix ./kde.nix ];

  # Some of these might be useful in getting wayland working
  # hardware.nvidia.powerManagement.enable = false;
  # hardware.opengl.enable = true;
  # hardware.opengl.driSupport32Bit = true;
  security.polkit.enable = true;
  # services.xserver.displayManager.gdm.wayland = true;

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    # Open drivers (NVreg_OpenRmEnableUnsupportedGpus=1)
    open = true;
    # nvidia-drm.modeset=1
    modesetting.enable = true;
    # NVreg_PreserveVideoMemoryAllocations=1
    # (does this solve the 'corruption after suspend' on wayland)?
    # https://github.com/NixOS/nixpkgs/issues/254614
    # powerManagement.enable = true;
  };
  # boot.extraModprobeConfig = ''
  #   options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp
  # '';

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  console.useXkbConfig = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    # extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  # Spotify nonsense
  # hardware.pulseaudio.daemon.config = { "enable-deferred-volume" = "no"; };

  # Firefox nonsense
  environment.sessionVariables.TZ = "${config.time.timeZone}";
}

