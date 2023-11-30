{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "udev" {
  services.udev.packages = with pkgs; [ opentx arduino ];
  services.udev.extraRules = ''
    # MUSE LAB ECP5 board
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="602b", MODE="0666"

    # Picoscope 2206B MSO
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0ce9", ATTRS{idProduct}=="1016", MODE="0666"

    # Crazyradio (normal operation)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", ATTRS{idProduct}=="7777", MODE="0664", GROUP="users"
    # Bootloader
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", ATTRS{idProduct}=="0101", MODE="0664", GROUP="users"
    # Crazyflie USB
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5740", MODE="0664", GROUP="users"
  '';
}
