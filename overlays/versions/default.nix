{ channels, ... }:

self: super: {
  anki = self.anki-23;

  fourmolu = self.haskell.packages.ghc96.fourmolu;

  # fzf = super.fzf.overrideAttrs (old: {
  #   patches = old.patches or [ ] ++ [ ../patches/fzf-tmux.patch ];
  # });
  # direnv = super.direnv.overrideAttrs (old: {
  #   patches = old.patches or [ ] ++ [ ../patches/quiet-direnv.patch ];
  # });
  atuin = super.atuin.overrideAttrs (old: rec {
    patches = old.patches or [ ] ++ [ ../patches/atuin-popup.patch ];
  });
  memtest86plus = self.callPackage ({ stdenv, fetchurl, lib }:
    stdenv.mkDerivation rec {
      pname = "memtest86+";
      version = "5.31b";

      src = fetchurl {
        url =
          "https://www.memtest.org/download/${version}/memtest86+-${version}.tar.gz";
        sha256 = "028zrch87ggajlb5xx1c2ab85ggl9qldpibf45735sy0haqzyiki";
      };

      hardeningDisable = [ "all" ];

      doCheck = stdenv.isi686;
      checkTarget = "run_self_test";

      installPhase = ''
        install -Dm0444 -t $out/ memtest.bin
      '';

      meta = with lib; {
        homepage = "https://www.memtest.org/";
        description = "An advanced memory diagnostic tool";
        license = licenses.gpl2Only;
        platforms = [ "x86_64-linux" "i686-linux" ];
        maintainers = with maintainers; [ evils ];
      };
    }) { };
}
