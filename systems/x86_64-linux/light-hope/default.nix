{ lib, pkgs, inputs, system
, # The system architecture for this host (eg. `x86_64-linux`).
target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
format, # A normalized name for the system target (eg. `iso`).
virtual
, # A boolean to determine whether this system is a virtual target using nixos-generators.
systems, # An attribute map of your defined hosts.
config, ... }:

{
  networking.hostName = "light-hope"; # Define your hostname.
  imports = [ ./impermanence.nix ./hardware ];
  ellie.desktop.enable = true;
  ellie.ollama.enable = true;
  ellie.comfyui.enable = true;
  ellie.nvidia.devDriver = false;
  ellie.debounce.enable = true;
  nix.settings.system-features = [ "gccarch-znver4" ];
  nixpkgs.config.allowUnfree = true;

  # Compile darktable (and its vendored rawspeed) with -march=native -mtune=native
  # for this specific machine (Ryzen 9 7950X3D / znver4). This trades binary cache
  # hits for maximum performance on the local CPU. The base optimizations
  # (Release, LTO, OpenCL, OpenMP) come from overlays/versions/default.nix.
  nixpkgs.overlays = [
    (final: prev: {
      darktable = prev.darktable.overrideAttrs (old: {
        # Flip the global BINARY_PACKAGE_BUILD=ON back to OFF so darktable's
        # own CMake adds -march=native too.
        cmakeFlags = (builtins.filter
          (f: f != "-DBINARY_PACKAGE_BUILD=ON")
          (old.cmakeFlags or [ ])) ++ [ "-DBINARY_PACKAGE_BUILD=OFF" ];
        # nixpkgs' cc-wrapper strips -m*=native by default; opt out per-package.
        # NIX_CFLAGS_COMPILE is consumed by the wrapper for both gcc and g++,
        # so a single setting covers C and C++ (rawspeed is C++).
        env = (old.env or { }) // {
          NIX_ENFORCE_NO_NATIVE = 0;
          NIX_CFLAGS_COMPILE =
            ((old.env or { }).NIX_CFLAGS_COMPILE or "")
            + " -march=native -mtune=native";
        };
      });
    })
  ];
  system.stateVersion = "23.11"; # Did you read the comment?

  programs.mosh.enable = true;
  networking.firewall = {
    enable = true; # Enable the firewall
    allowedTCPPorts = [ 8000 8080 8081 8082 ]; # Open TCP ports
  };

  security.pki.certificateFiles = [ ./certs/ultimate-guitar.crt ];

}
