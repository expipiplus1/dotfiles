{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      draw_bold_text_with_bright_colors = false;
      window.dimensions = {
        lines = 84;
        columns = 295;
      };
      font = {
        size = 8;
      } // pkgs.lib.mapAttrs (name: value: {
        family = "DejaVu Sans Mono Nerd Font";
        # or family = "DejaVu Sans Mono";
        style = value;
      }) {
        normal = "Book";
        bold = "Bold";
        italic = "Oblique";
        bold_italic = "Bold Oblique";
      };
    };
  };
}
