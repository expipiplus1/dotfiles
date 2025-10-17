{ channels, ... }:

self: super: {
  anki = super.anki.overrideAttrs (old: {
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
    postFixup = old.postFixup or "" + ''
      wrapProgram "$out/bin/signal-desktop" --add-flags --ozone-platform-hint=auto
    '';
  });

  vscode-extensions = super.vscode-extensions // {
    ms-vscode = super.vscode-extensions.ms-vscode // {
      cpptools = super.vscode-extensions.ms-vscode.cpptools.overrideAttrs
        (oldAttrs: {
          postPatch = oldAttrs.postPatch + ''
            cp debugAdapters/bin/cppdbg.ad7Engine.json debugAdapters/bin/nvim-dap.ad7Engine.json
          '';
        });
    };
  };

  fd = super.fd.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [ self.makeWrapper ];
    postFixup = old.postFixup or "" + ''
      wrapProgram "$out/bin/fd" --add-flags --no-require-git
    '';
  });

  # ripgrep = super.ripgrep.overrideAttrs (old: {
    # nativeBuildInputs = old.nativeBuildInputs ++ [ self.makeWrapper ];
    # postFixup = old.postFixup or "" + ''
      # wrapProgram "$out/bin/rg" --add-flags --no-require-git
    # '';
  # });
}
