{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "fonts" (let
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

  myIosevka = family: plan:
    disableParallelBuilding (pkgs.iosevka.override {
      set = builtins.replaceStrings [ " " ] [ "-" ] (lib.toLower family);
      privateBuildPlan = defaultIosevkaPlan // {
        family = "Iosevka " + family;
      } // plan;
    });
in {
  fonts.packages = with pkgs; [
    (myIosevka "Term" {
      spacing = "term";
      serifs = "sans";
    })
    (myIosevka "Aile" {
      spacing = "quasi-proportional";
      serifs = "sans";
    })
    (myIosevka "Etoile" {
      spacing = "quasi-proportional";
      serifs = "slab";
    })
    # (iosevka-bin.override { variant = "etoile"; })
    # (iosevka-bin.override { variant = "aile"; })
    # (iosevka-bin.override { variant = "sgr-iosevka-fixed"; })
    # (iosevka-bin.override { variant = "sgr-iosevka-term"; })
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
    # material-design-icons

    # For nicer Chinese character rendering
    wqy_zenhei
    cm_unicode
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "Iosevka Fixed" ];
    # sansSerif = [ "Iosevka Aile" ];
    # serif = [ "Iosevka Etoile" ];
    emoji = [ "Material Design Icons" ];
  };
})
