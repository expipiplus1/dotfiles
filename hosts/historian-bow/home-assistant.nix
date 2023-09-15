{ config, pkgs, ... }:
let
  sources = {
    smartir = pkgs.fetchFromGitHub {
      owner = "smartHomeHub";
      repo = "SmartIR";
      rev = "61e2960ec46cd766703f0fc9a756e7b6c3ceefad";
      sha256 = "sha256-4YMn+7IhDQEVQ6B51qZ5NmqRfN55l0Eycm9XcAwLO3U=";
    };
  };
in {
  networking.firewall = { allowedTCPPorts = [ 8123 ]; };
  services.nginx = {
    virtualHosts."ass.home.monoid.al" = {
      forceSSL = true;
      enableACME = true;
      extraConfig = ''
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://[::1]:8123";
        proxyWebsockets = true;
      };
    };
  };

  services.home-assistant = {
    enable = true;

    # Components might not actually have YAML configuration, but
    # mentioning them in the configuration will get their dependencies
    # loaded.
    config = {
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      script = "!include scripts.yaml";
      automation = "!include automations.yaml";
      # https://www.home-assistant.io/integrations/esphome/
      # esphome = {};
      # https://www.home-assistant.io/integrations/met/
      # met = {};
      broadlink = { };
      backup = { };
      zha = { };
      smartir = { };
      climate = [
        {
          platform = "smartir";
          name = "living room ac";
          unique_id = "lr_ac";
          device_code = 1114;
          controller_data = "remote.living_room_ir";
        }
        {
          platform = "smartir";
          name = "hall ac";
          unique_id = "hall_ac";
          device_code = 1114;
          controller_data = "remote.hall_ir";
        }
        {
          platform = "smartir";
          name = "bedroom ac";
          unique_id = "bedroom_ac";
          device_code = 1119;
          controller_data = "remote.bedroom_ir";
        }
        {
          platform = "smartir";
          name = "study ac";
          unique_id = "study_ac";
          device_code = 1692;
          controller_data = "remote.study_ir";
        }
      ];
      http = {
        cors_allowed_origins = [ "https://keitetran.github.io" ];
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
    };
    package = (pkgs.home-assistant.override {
      extraPackages = py:
        with py; [
          aiofiles
          (buildPythonPackage rec {
            pname = "libdyson";
            version = "0.8.11";
            src = fetchPypi {
              inherit pname version;
              sha256 = "sha256-yvHzE6Qc46vinRdV5Xfg+A0AhWCh+yWOtDyrQ/xC2Xs=";
            };
            propagatedBuildInputs =
              [ zeroconf attrs paho-mqtt cryptography requests ];
            doCheck = false;
          })
        ];
    }).overrideAttrs (oldAttrs: { doInstallCheck = false; });
  };
  systemd.tmpfiles.rules = [
    "Z /var/lib/hass/custom_components 770 hass hass - -"
    "C /var/lib/hass/custom_components/smartir - - - - ${sources.smartir}/custom_components/smartir"
    "C /var/lib/hass/custom_components/smartir/codes/climate/1114.json - - - - ${
      ./aircon-codes/FCQ100KAVEA.json
    }"
    "C /var/lib/hass/custom_components/smartir/codes/climate/1119.json - - - - ${
      ./aircon-codes/1119.json
    }"
    "C /var/lib/hass/custom_components/smartir/codes/climate/1692.json - - - - ${
      ./aircon-codes/1692.json
    }"
  ];
}
