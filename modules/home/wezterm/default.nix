{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "wezterm" {
  home.packages = [ pkgs.wezterm ];
  xdg.configFile."wezterm/wezterm.lua".source = pkgs.writeText "wezterm.lua" ''
    local wezterm = require 'wezterm';

    return {
      font = wezterm.font_with_fallback{
        { family = "Iosevka Term"
        , weight = "Regular"
        , harfbuzz_features = {"calt=0", "dlig=0", "cv58=2", "cv36=1"} -- curly lambda λ <3
        }
        , "DejaVu Sans Mono Nerd Font Mono"
        , "DejaVu Sans Mono"
      };

      font_size = 8.5;
      initial_rows = 84;
      initial_cols = 295;
      hide_tab_bar_if_only_one_tab = true;
      window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      };

      audible_bell = "Disabled";

      color_scheme = "nord";
    }
  '';
}

