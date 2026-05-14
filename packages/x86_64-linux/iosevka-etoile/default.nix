{ lib, iosevka, ... }:

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
disableParallelBuilding (iosevka.override {
  set = "etoile";
  privateBuildPlan = defaultIosevkaPlan // {
    family = "Iosevka Etoile";
    spacing = "quasi-proportional";
    serifs = "slab";
  };
})
