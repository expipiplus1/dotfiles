{ config, pkgs, ... }:

#
# Misc things, too small for their own module
#

{
  time.timeZone = "Asia/Singapore";

  # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.systemPackages = with pkgs; [ git vim ];

  services.nixseparatedebuginfod.enable = true;
}
