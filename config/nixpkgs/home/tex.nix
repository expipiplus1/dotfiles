{ config, pkgs, ... }:

{
  programs.texlive = {
    enable = true;
    extraPackages = tpkgs: {
      inherit (tpkgs)
        amsmath babel beamer booktabs cm-super collection-fontsextra
        collection-fontsrecommended draftwatermark ec eso-pic etoolbox euenc
        everypage filehook fontspec greek-inputenc koma-script lm mathspec
        mdframed metafont microtype needspace parskip pgf pgfgantt pgfkeyx
        scheme-basic siunitx standalone ucharcat unicode-math vntex wallpaper
        xcolor xetex xkeyval xunicode zapfding;
    };
  };
}
