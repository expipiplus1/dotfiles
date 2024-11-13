{ channels, ... }:

self: super: {
  neovim = channels.nixpkgs-unstable.neovim;
  neovim-unwrapped = channels.nixpkgs-unstable.neovim-unwrapped;

  rust-parallel = channels.nixpkgs-unstable.rust-parallel;
  difftastic = channels.nixpkgs-unstable.difftastic;
  clang-tools = channels.nixpkgs-unstable.llvmPackages_18.clang-tools;
  lazyjj = channels.nixpkgs-unstable.lazyjj;
  jujutsu = channels.nixpkgs-unstable.jujutsu;

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

  starship = super.starship.override {
    rustPlatform = self.rustPlatform // {
      buildRustPackage = args:
        self.rustPlatform.buildRustPackage (args // {
          src = self.fetchFromGitHub {
            owner = "idursun";
            repo = "starship";
            rev = "7226aaedf2dd0dd34a7373859d25da45c7cd3eaa";
            sha256 = "sha256-m0eA4Kv5RikMcnYqRlGnyHV1bQS3kDgHhGYGqTvbZBE=";
          };
          cargoHash = "sha256-d6i9+gnkt4wXzqB8+eLofX4enejG/YYiJAtg7KimA6M=";
        });
    };
  };

  tree-sitter = super.tree-sitter.overrideAttrs (old: {
    passthru.buildGrammar = x:
      if x.language == "haskell" then
        old.passthru.buildGrammar (x // {
          src = self.fetchFromGitHub {
            owner = "tek";
            repo = "tree-sitter-haskell";
            sha256 = "0kpg1c87magrcgp365kmvnfjq9c0mlc81mx4vdz22p00jfynmin3";
            rev = "3a965b242b1a6553097b8c0d12c4989074d74b5f";
          };
          generate = true;
        })
      else
        old.passthru.buildGrammar x;
  });
}
