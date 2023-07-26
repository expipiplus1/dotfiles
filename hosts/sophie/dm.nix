{ config, pkgs, ... }:
let
  monitorsXmlContent = builtins.readFile ./monitors.xml;
  monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in {
  imports = [ ../shared/dm.nix ];

  systemd.tmpfiles.rules =
    [ "L+ /run/gdm/.config/monitors.xml - - - - ${monitorsConfig}" ];
}
