{ channels, ... }:

self: super: {
  stylua = super.symlinkJoin {
    name = "stylua-wrapped";
    paths = [ super.stylua ];
    buildInputs = [ super.makeWrapper ];
    postBuild = ''
            # Move the original binary to a hidden name
            mv $out/bin/stylua $out/bin/.stylua-wrapped

            # Create the wrapper script
            cat <<EOF > $out/bin/stylua
      #!/bin/sh
      # Log the date, working directory, and all arguments
      echo "--- \$(date '+%Y-%m-%d %H:%M:%S') ---" >> ~/tmp/stylua.log
      echo "PWD: \$PWD" >> ~/tmp/stylua.log
      echo "ARGS: \$@" >> ~/tmp/stylua.log

      # Execute the real binary with the passed arguments
      exec $out/bin/.stylua-wrapped "\$@"
      EOF
            chmod +x $out/bin/stylua
    '';
  };

  # Use full UniDic instead of the default ipadic dictionary for MeCab
  unidic = super.fetchzip {
    url = "https://cotonoha-dic.s3-ap-northeast-1.amazonaws.com/unidic-3.1.0.zip";
    hash = "sha256-Phyrbf5YlBK1qK/wq+YO42mVLNiE8fK2jPH1aofsT4M=";
    stripRoot = false;
  };

  mecab = super.mecab.overrideAttrs (old: {
    postInstall = ''
      mkdir -p $out/lib/mecab/dic
      ln -s ${self.unidic}/unidic $out/lib/mecab/dic/unidic
      # Point mecabrc to unidic instead of ipadic
      substituteInPlace $out/etc/mecabrc \
        --replace-fail "/lib/mecab/dic/ipadic" "/lib/mecab/dic/unidic"
    '';
  });

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

  ripgrep = super.ripgrep.overrideAttrs (old: {
    checkPhase = ":";
    dontCheck = true;
    nativeBuildInputs = old.nativeBuildInputs ++ [ self.makeWrapper ];
    postFixup = old.postFixup or "" + ''
      wrapProgram "$out/bin/rg" --add-flags --no-require-git
    '';
  });

  btop = super.btop.override { cudaSupport = true; };

  nix = super.nix.overrideAttrs (old: {
    doCheck = false;
    buildInputs = builtins.filter
      (i: !(builtins.hasAttr "pname" i && i.pname == "nix-functional-tests"))
      (old.buildInputs or []);
  });

  # Apply local fixes for KDE bug 506054 to spectacle. These patches make
  # rectangular-region capture work when the active monitor's logical
  # position is not (0, 0) (e.g. with a Valve Index headset or a
  # connected-but-disabled second output occupying x=0..N to the left of
  # the active monitor).
  #
  # The patches are also kept as a `bug-506054-fixes` branch in the
  # working spectacle checkout at ~/src/spectacle, generated with
  # `git format-patch origin/Plasma/6.5..bug-506054-fixes`. They apply
  # cleanly to the upstream Plasma 6.5.6 tarball with no fuzz; refresh
  # them whenever nixpkgs bumps spectacle to a release that doesn't
  # already include them. Investigation notes:
  # ~/src/SPECTACLE-REGION-HANG-BUG.md.
  kdePackages = super.kdePackages.overrideScope (kdeSelf: kdeSuper: {
    spectacle = kdeSuper.spectacle.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ../patches/spectacle-bug-506054/0001-AnnotationDocument-honour-image-s-logicalXY-in-canva.patch
        ../patches/spectacle-bug-506054/0002-SpectacleCore-translate-accepted-region-to-canvas-lo.patch
        ../patches/spectacle-bug-506054/0003-SelectionEditor-don-t-reset-screensRect-to-origin-fo.patch
        ../patches/spectacle-bug-506054/0004-CaptureOverlay-clamp-toolbars-against-screensRect-s-.patch
        ../patches/spectacle-bug-506054/0005-ImagePlatformKWin-emit-newScreenshotCanceled-when-ev.patch
      ];
    });
  });
}
