{ config, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    modesetting.enable = true;

    # The open drivers have problems suspending
    # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/472
    open = false;

    # NVreg_PreserveVideoMemoryAllocations=1
    # (does this solve the 'corruption after suspend' on wayland)?
    # https://github.com/NixOS/nixpkgs/issues/254614
    powerManagement.enable = true;

    # make the settings app available
    nvidiaSettings = true;
  };

  # Make the driver suspend gpu memory to disk, /run is tmpfs on nixos, and
  # probably won't meet the recommended size of
  # `nvidia-smi -q -d MEMORY | grep 'FB Memory Usage' -A1`
  systemd.tmpfiles.rules = [ "d /var/nvidia-suspend 0770 root root -" ];
  boot.extraModprobeConfig = ''
    options nvidia NVreg_TemporaryFilePath=/var/nvidia-suspend
  '';

  services.xserver = { videoDrivers = [ "nvidia" ]; };
}

