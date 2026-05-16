{ lib, config, pkgs, ... }:

let
  cfg = config.ellie.fonts;

  mkIosevka = { set, family, spacing, serifs }:
    let
      disableParallelBuilding = drv:
        drv.overrideAttrs (old: { enableParallelBuilding = false; });

      defaultIosevkaPlan = {
        noCvSs = true;
        exportGlyphNames = false;
        noLigation = true;
        variants = {
          design = { lower-lambda = "straight-turn"; };
          italic = { k = "straight-serifless"; };
        };

        weights = {
          extralight = {
            shape = 200;
            menu = 200;
            css = 200;
          };

          regular = {
            shape = 400;
            menu = 400;
            css = 400;
          };

          semibold = {
            shape = 600;
            menu = 600;
            css = 600;
          };
        };

        slopes = {
          upright = {
            angle = 0;
            shape = "upright";
            menu = "upright";
            css = "normal";
          };

          italic = {
            angle = 9.4;
            shape = "italic";
            menu = "italic";
            css = "italic";
          };
        };
      };
    in
    disableParallelBuilding (pkgs.iosevka.override {
      inherit set;
      privateBuildPlan = defaultIosevkaPlan // {
        inherit family spacing serifs;
      };
    });

in {
  options.ellie.fonts = {
    enable = lib.mkEnableOption "the fonts module";

    iosevka-term = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = mkIosevka {
        set = "term";
        family = "Iosevka Term";
        spacing = "term";
        serifs = "sans";
      };
      description = "Custom Iosevka Term package.";
    };

    iosevka-aile = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = mkIosevka {
        set = "aile";
        family = "Iosevka Aile";
        spacing = "quasi-proportional";
        serifs = "sans";
      };
      description = "Custom Iosevka Aile package.";
    };

    iosevka-etoile = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = mkIosevka {
        set = "etoile";
        family = "Iosevka Etoile";
        spacing = "quasi-proportional";
        serifs = "slab";
      };
      description = "Custom Iosevka Etoile package.";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = [
      cfg.iosevka-term
      cfg.iosevka-aile
      cfg.iosevka-etoile
      pkgs.nerd-fonts.symbols-only

      # CJK fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
      pkgs.wqy_zenhei
      pkgs.cm_unicode
    ];

    fonts.fontconfig.defaultFonts = {
      monospace = [ "Iosevka Fixed" ];
      emoji = [ "Material Design Icons" ];
    };
  };
}
