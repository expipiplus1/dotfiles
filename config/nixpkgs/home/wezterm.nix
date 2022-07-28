{config, pkgs, ...}:

{
  home.packages = [ pkgs.wezterm ];
  xdg.configFile."wezterm/wezterm.lua".source =
    pkgs.writeText "wezterm.lua" ''
      local wezterm = require 'wezterm';

      return {
        font = wezterm.font_with_fallback({
          "DejaVu Sans Mono Nerd Font Mono",
          "DejaVu Sans Mono"
        });

        font_size = 8.5;
        initial_rows = 84 ;
        initial_cols = 295;
        hide_tab_bar_if_only_one_tab = true;
        window_padding = {
          left = 0,
          right = 0,
          top = 0,
          bottom = 0,
        }
      }
  '';
}

