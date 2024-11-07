{ pkgs, config, ... }:

let
  m = { pkgs, lib, kernel ? pkgs.linuxPackages_latest.kernel }:

    pkgs.stdenv.mkDerivation {
      pname = "hwmon-modules";
      inherit (kernel) src version postPatch nativeBuildInputs;

      kernel_dev = kernel.dev;
      kernelVersion = kernel.modDirVersion;

      modulePath = "drivers/hwmon";

      buildPhase = ''
        BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

        cp $BUILT_KERNEL/Module.symvers .
        cp $BUILT_KERNEL/.config        .
        cp $kernel_dev/vmlinux          .

        make "-j$NIX_BUILD_CORES" modules_prepare
        make "-j$NIX_BUILD_CORES" M=$modulePath modules
      '';

      installPhase = ''
        make \
          INSTALL_MOD_PATH="$out" \
          XZ="xz -T$NIX_BUILD_CORES" \
          M="$modulePath" \
          modules_install
      '';

      meta = {
        description = "Asus ec sensors module";
        license = lib.licenses.gpl3;
      };
    };

  asus-ec-sensors-kernel-module = pkgs.callPackage m {
    # Make sure the module targets the same kernel as your system is using.
    kernel = config.boot.kernelPackages.kernel;
  };

in {
  boot.initrd.availableKernelModules =
    [ "nvme" "thunderbolt" "xhci_pci" "ahci" "usbhid" "aesni_intel" "cryptd" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" "nct6775" ];
  boot.extraModulePackages = [ asus-ec-sensors-kernel-module ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "btrfs" ];
  hardware.enableAllFirmware = true;

  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.initrd.luks.devices = {
    enc = {
      device = "/dev/disk/by-uuid/4b3b1950-e298-49e1-a9e0-5890b737baab";
      preLVM = true;
      # see https://asalor.blogspot.de/2011/08/trim-dm-crypt-problems.html before enabling
      allowDiscards = true;
      # improve SSD performance
      bypassWorkqueues = true;
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
