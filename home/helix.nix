{ config, lib, pkgs, ... }:

with lib;

let
  base16Themes = pkgs.fetchFromGitHub {
    owner = "tinted-theming";
    repo = "base16-helix";
    rev = "10edc31ac6d110050f98ee4d14d8e5c48e1a0104";
    sha256 = "0qmbkal3mq7hfbhc4wxgr0sa4nx87xfq7i3bww8n38pqahmnvw7d";
  };

  themes = pkgs.symlinkJoin {
    name = "helix-themes";
    paths = [ (base16Themes + "/themes") ];
  };

in {
  programs.helix = {
    enable = true;

    settings = { theme = "nord"; };
  };
  xdg.configFile."helix/themes".source = themes;
}

