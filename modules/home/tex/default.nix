{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "tex" {
  home.packages = with pkgs; [ pandoc pdftk ];

  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: { inherit (tpkgs) scheme-small; };
    # extraPackages = tpkgs:
    #   {
    #     inherit (tpkgs)
    #       amsmath babel beamer booktabs cm-super collection-fontsextra
    #       collection-fontsrecommended draftwatermark ec eso-pic etoolbox euenc
    #       everypage fancyvrb filehook fontspec greek-inputenc koma-script lm
    #       mathspec mdframed metafont microtype needspace parskip pgf pgfgantt
    #       pgfkeyx scheme-basic siunitx standalone ucharcat unicode-math vntex
    #       wallpaper xcolor xetex xkeyval xunicode zapfding typewriter
    #       cm-unicode;
    #   } // { # Doxygen
    #     inherit (tpkgs)
    #       float varwidth multirow hanging adjustbox stackengine ulem sectsty
    #       tocloft refman newunicodechar caption etoc collectbox listofitems;
    #   };
  };
}
