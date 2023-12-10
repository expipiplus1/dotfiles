{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "bluetooth" {
  hardware.xpadneo.enable = true;
  hardware.bluetooth = {
    enable = true;
    settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
  };

  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.msbc-support"] = true,
        ["bluez5.codecs"] = "[sbc sbc_xq]",
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };
  services.pipewire.wireplumber.enable = true;
  # services.pipewire = {
  #   media-session.config.bluez-monitor.rules = [
  #     {
  #       # Matches all cards
  #       matches = [{ "device.name" = "~bluez_card.*"; }];
  #       actions = {
  #         "update-props" = {
  #           "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
  #           # mSBC is not expected to work on all headset + adapter combinations.
  #           "bluez5.msbc-support" = true;
  #           # SBC-XQ is not expected to work on all headset + adapter combinations.
  #           "bluez5.sbc-xq-support" = true;
  #         };
  #       };
  #     }
  #     {
  #       matches = [
  #         # Matches all sources
  #         {
  #           "node.name" = "~bluez_input.*";
  #         }
  #         # Matches all outputs
  #         { "node.name" = "~bluez_output.*"; }
  #       ];
  #     }
  #   ];
  # };
}
