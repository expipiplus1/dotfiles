{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      draw_bold_text_with_bright_colors = false;
      window.dimensions = {
        lines = 67;
        columns = 240;
      };
    };
  };
}
