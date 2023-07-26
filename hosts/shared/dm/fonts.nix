{ config, pkgs, ... }: {
  fonts.fonts = with pkgs; [
    # For nicer Chinese character rendering
    wqy_zenhei
    cm_unicode
    (iosevka-bin.override { variant = "etoile"; })
    (iosevka-bin.override { variant = "aile"; })
    (iosevka-bin.override { variant = "sgr-iosevka-fixed"; })
    (iosevka-bin.override { variant = "sgr-iosevka-term"; })
    (nerdfonts.override { fonts = [ "Monoid" ]; })
    material-design-icons
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "Iosevka Fixed" ];
    # sansSerif = [ "Iosevka Aile" ];
    # serif = [ "Iosevka Etoile" ];
    emoji = [ "Material Design Icons" ];
  };
}
