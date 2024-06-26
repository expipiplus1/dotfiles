{ channels, ... }:

self: super: {
  anki-23 = channels.nixpkgs-master.anki.overrideAttrs (old: {
    buildInputs = old.buildInputs ++ [ self.makeWrapper ];
    postInstall = old.postInstall or "" + ''
      # Fix jagged text rendering, as per
      # https://github.com/ankitects/anki/issues/1767
      # https://bugreports.qt.io/browse/QTBUG-113574
      wrapProgram "$out/bin/anki" \
        --set QT_SCALE_FACTOR_ROUNDING_POLICY RoundPreferFloor \
        --suffix PATH ":" ${
          self.lib.makeBinPath [ self.goldendict-ng self.mecab ]
        }
    '';
  });

  signal-desktop = super.signal-desktop.overrideAttrs (old: {
    postFixup = old.postFixip or "" + ''
      wrapProgram "$out/bin/signal-desktop" --add-flags --ozone-platform-hint=auto
    '';
  });

  nixos-option = self.nixos-rebuild;
}
