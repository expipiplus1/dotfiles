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
      font = {size = 10.5;} // pkgs.lib.mapAttrs (name: value: {
        family = "DejaVu Sans Mono";
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
