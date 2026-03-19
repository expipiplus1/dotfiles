{ lib, pkgs, config, ... }@inputs:
let
  haPackage = config.services.home-assistant.package;
  haPython = haPackage.python.pkgs;

  libdyson-rest = haPython.buildPythonPackage rec {
    pname = "libdyson-rest";
    version = "0.12.1";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "cmgrayb";
      repo = "libdyson-rest";
      rev = "v${version}";
      hash = "sha256-zurbG5R7g7IlGuTMjhLkd+np5uUPW5eWifHYWWWb7ns=";
    };

    build-system = [ haPython.setuptools ];

    dependencies = with haPython; [
      requests
      httpx
      cryptography
      typing-extensions
    ];

    doCheck = false;
  };

  buildHomeAssistantComponent = pkgs.callPackage "${pkgs.path}/pkgs/servers/home-assistant/build-custom-component" {
    home-assistant = haPackage;
  };

  hass-dyson = buildHomeAssistantComponent rec {
    owner = "cmgrayb";
    domain = "hass_dyson";
    version = "0.30.0";

    src = pkgs.fetchFromGitHub {
      owner = "cmgrayb";
      repo = "hass-dyson";
      tag = "v${version}";
      hash = "sha256-F+a7izYvKdjY0eMI1k1DFRXUiLOcW+zSlrhg+2iiSDY=";
    };

    dependencies = [ libdyson-rest haPython.paho-mqtt ];
  };
in
lib.internal.simpleModule inputs "home-assistant" {
  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.home-assistant = {
    enable = true;
    extraPackages = ps: with ps; [
      broadlink
      getmac
    ];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      mini-graph-card
    ];
    customComponents = [
      hass-dyson
    ];
    config = {
      default_config = { };
      script = "!include scripts.yaml";
      automation = "!include automations.yaml";
      backup = { };
      zha = { };
      smartir = { };
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
    };
  };
}
