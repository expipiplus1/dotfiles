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
  });
}
