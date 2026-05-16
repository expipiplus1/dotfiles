{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "fonts" {
  fonts.packages = with pkgs; [
    iosevka-term
    iosevka-aile
    iosevka-etoile
    nerd-fonts.symbols-only

    # CJK fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    wqy_zenhei
    cm_unicode
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "Iosevka Fixed" ];
    emoji = [ "Material Design Icons" ];
  };
}
