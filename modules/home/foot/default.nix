{ lib, ... }@inputs:
lib.internal.simpleModule inputs "foot" {
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Iosevka Term:size=10:style=Regular";
        font-bold = "Iosevka Term:size=10:style=Semibold";
        font-italic = "Iosevka Term:size=10:style=Italic";
        font-bold-italic = "Iosevka Term:size=10:style=Semibold Italic";
        # box-drawings-uses-font-glyphs = "yes";
        initial-window-mode = "maximized";
        dpi-aware = "yes";
      };
      tweak = { damage-whole-window = "yes"; };
      cursor = {
        color = "2e3440 d8dee9";
        beam-thickness = 0.8;
      };
      colors = {
        foreground = "d8dee9";
        background = "2e3440";

        # selection-foreground = "d8dee9";
        # selection-background = "4c566a";

        regular0 = "3b4252";
        regular1 = "bf616a";
        regular2 = "a3be8c";
        regular3 = "ebcb8b";
        regular4 = "81a1c1";
        regular5 = "b48ead";
        regular6 = "88c0d0";
        regular7 = "e5e9f0";

        bright0 = "4c566a";
        bright1 = "bf616a";
        bright2 = "a3be8c";
        bright3 = "ebcb8b";
        bright4 = "81a1c1";
        bright5 = "b48ead";
        bright6 = "8fbcbb";
        bright7 = "eceff4";

        dim0 = "373e4d";
        dim1 = "94545d";
        dim2 = "809575";
        dim3 = "b29e75";
        dim4 = "68809a";
        dim5 = "8c738c";
        dim6 = "6d96a5";
        dim7 = "aeb3bb";
      };
      csd = {
        preferred = "client";
        hide-when-maximized = "yes";
      };
      key-bindings = { fullscreen = "Control+Shift+F"; };
    };
  };
}
