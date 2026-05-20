{ lib, config, pkgs, ... }:

let
  devDriver = (config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "570.00";
    url =
      "http://dvstransfer.nvidia.com/dvsshare/dvs-binaries/gpu_drv_bugfix_main_Release_Linux_AMD64_unix-build_Driver/SW_35299177.0_gpu_drv_bugfix_main_Release_Linux_AMD64_unix-build_Driver.run";
    sha256_64bit = "sha256-vOuE7VPlySS8rkhMnpZ2ZHYzQANvpF5FbP83ABkmNJU=";
    useSettings = false;
    usePersistenced = false;
  }).override { disable32Bit = true; };

in with lib; {
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

  config = mkIf config.ellie.nvidia.enable {
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.nvidia.acceptLicense = true;
    # Work around: DRM kernel driver 'nvidia-drm' in use. NVK requires nouveau.
    environment.sessionVariables.VK_DRIVER_FILES =
      "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json";
    hardware.nvidia = {
      package = if config.ellie.nvidia.devDriver then
        devDriver
      else
        config.boot.kernelPackages.nvidiaPackages.stable;

      modesetting.enable = true;

      # 595+ dropped proprietary kernel modules — open is the only option
      open = true;

      # 595+ open modules support kernel suspend notifiers, which handle
      # save/restore of GPU state natively — no systemd services needed.
      # NixOS automatically sets NVreg_PreserveVideoMemoryAllocations=1
      # and NVreg_UseKernelSuspendNotifiers=1 for open modules on 595+.
      powerManagement.enable = true;

      # make the settings app available
      nvidiaSettings = if config.ellie.nvidia.devDriver then false else true;
      gsp.enable = if config.ellie.nvidia.devDriver then false else true;
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    # Expose NVIDIA OpenCL ICD so that ocl-icd can find it
    hardware.graphics.extraPackages = [ config.hardware.nvidia.package ];
  };
}
