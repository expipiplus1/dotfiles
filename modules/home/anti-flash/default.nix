{ lib, pkgs, ... }@inputs:

let
  anti-flash = pkgs.stdenv.mkDerivation {
    pname = "anti-flash";
    version = "0.1.0";

    src = ./src;

    nativeBuildInputs = [ pkgs.wayland-scanner pkgs.pkg-config ];
    buildInputs = [ pkgs.wayland pkgs.wayland-protocols pkgs.wlr-protocols ];

    buildPhase = ''
      runHook preBuild

      # Generate layer-shell protocol glue
      layer_shell_xml=$(find ${pkgs.wlr-protocols}/share -name 'wlr-layer-shell-unstable-v1.xml' | head -1)
      wayland-scanner client-header "$layer_shell_xml" layer-shell-client-protocol.h
      wayland-scanner private-code  "$layer_shell_xml" layer-shell-protocol.c

      # Generate xdg-shell protocol glue (dependency of layer-shell)
      xdg_shell_xml=$(find ${pkgs.wayland-protocols}/share -name 'xdg-shell.xml' | head -1)
      wayland-scanner client-header "$xdg_shell_xml" xdg-shell-client-protocol.h
      wayland-scanner private-code  "$xdg_shell_xml" xdg-shell-protocol.c

      $CC -Wall -Wextra -O2 \
        $(pkg-config --cflags wayland-client) -I. \
        -o anti-flash \
        anti-flash.c layer-shell-protocol.c xdg-shell-protocol.c \
        $(pkg-config --libs wayland-client) -lrt

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm755 anti-flash $out/bin/anti-flash
      runHook postInstall
    '';
  };

in lib.internal.simpleModule inputs "anti-flash" {
  systemd.user.services.anti-flash = {
    Unit = {
      Description = "Prevent monitor flashing from identical frames";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${anti-flash}/bin/anti-flash";
      Nice = 19;
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
