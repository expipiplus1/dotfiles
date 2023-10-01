{ config, pkgs, ... }:

{
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

  services.xserver = { videoDrivers = [ "nvidia" ]; };
}

