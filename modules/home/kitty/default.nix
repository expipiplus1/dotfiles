{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "kitty" {
  programs.kitty = {
    enable = false;
    extraConfig = ''
      font_family Iosevka Term
      bold_font Iosevka Term Semibold
      italic_font Iosevka Term Italic
      bold_italic_font Iosevka Term Semibold Italic
      font_size 8.5


      ${pkgs.lib.concatLines (map ({ a, b, c }:
        "font_features Iosevka-Term${a}${b}${c} calt=0 dlig=0 cv58=2 cv36=1 cv26=2")
        (pkgs.lib.cartesianProductOfSets {
          a = [
            ""
            "-Bold"
            "-Extrabold"
            "-Extralight"
            "-Heavy"
            "-Light"
            "-Medium"
            "-Semibold"
            "-Thin"
          ];
          b = [ "" "-Extended" ];
          c = [ "" "-Italic" "-Oblique" ];
        }))}

      # text_composition_strategy 0.4 0

      map ctrl+shift+plus change_font_size all +0.5
      map ctrl+shift+equal change_font_size all +0.5
      map ctrl+shift+minus change_font_size all -0.5

      enable_audio_bell no

      cursor_beam_thickness 1

      include ${
        builtins.fetchurl {
          url =
            "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/kitty/nord.conf";
          sha256 = "0pb0j8c5cvzsx79dckyz8nlx3sz9n3wbwmhrw5f9j2p11js4ayjc";
        }
      }
    '';
  };
}

