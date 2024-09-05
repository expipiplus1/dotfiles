{ lib, config, pkgs, ... }@inputs:

let devDriver = null;

in with inputs.lib; {
  options.ellie.nvidia = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    devDriver = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf inputs.config.ellie.nvidia.enable {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.nvidia.acceptLicense = true;
    # Work around: DRM kernel driver 'nvidia-drm' in use. NVK requires nouveau.
    environment.sessionVariables.VK_DRIVER_FILES =
      "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    hardware.nvidia = {
      package = if config.ellie.nvidia.devDriver then
        devDriver
      else
        config.boot.kernelPackages.nvidiaPackages.beta;

      modesetting.enable = true;

      # The open drivers have problems suspending
      # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/472
      open = false;

      # NVreg_PreserveVideoMemoryAllocations=1
      # (does this solve the 'corruption after suspend' on wayland)?
      # https://github.com/NixOS/nixpkgs/issues/254614
      powerManagement.enable = true;

      # make the settings app available
      nvidiaSettings = if config.ellie.nvidia.devDriver then false else true;
    };

    # Make the driver suspend gpu memory to disk, /run is tmpfs on nixos, and
    # probably won't meet the recommended size of
    # `nvidia-smi -q -d MEMORY | grep 'FB Memory Usage' -A1`
    systemd.tmpfiles.rules = [ "d /var/nvidia-suspend 0770 root root -" ];
    boot.extraModprobeConfig = ''
      options nvidia NVreg_TemporaryFilePath=/var/nvidia-suspend
    '';

    services.xserver.videoDrivers = [ "nvidia" ];
  };
}
