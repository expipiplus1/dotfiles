{ config, pkgs, ... }: {
  hardware.bluetooth.enable = true;
  # hardware.bluetooth.settings = {
  #   General = {
  #     Experimental = true;
  #   };
  # };
  # hardware.bluetooth.hsphfpd.enable = true;
  # Xbox controller stuff
  # boot.extraModprobeConfig = "options bluetooth disable_ertm=1";
  hardware.xpadneo.enable = true;

  hardware.bluetooth.settings = {
    General = { Enable = "Source,Sink,Media,Socket"; };
  };
}
