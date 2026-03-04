{ channels, ... }:

self: super: {
  tmux = super.tmux.overrideAttrs (old: rec {
    version = "master-2026-03-01";
    src = self.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      rev = "4cb29deb93358b8aa6b57f7a4886aa4d5dabd270";
      hash = "sha256-m7x/hhuSxuqBmq2y4UbzsFntUw6UK2oLqGkVK7XhsjQ=";
    };
    nativeBuildInputs = old.nativeBuildInputs ++ [ self.autoreconfHook ];
  });
  claude-code-acp = channels.nixpkgs-unstable.claude-code-acp;
  perf = channels.nixpkgs-unstable.perf;
  # linuxPackages = channels.nixpkgs-unstable.linuxPackages;
  neovim = channels.nixpkgs-unstable.neovim;
  neovim-unwrapped = channels.nixpkgs-unstable.neovim-unwrapped;

  code-cursor = channels.nixpkgs-unstable.code-cursor;
  cursor-cli = channels.nixpkgs-unstable.cursor-cli;
  gemini-cli = channels.nixpkgs-gemini.gemini-cli;
  claude-code = channels.nixpkgs-claude.claude-code;

  rust-parallel = channels.nixpkgs-unstable.rust-parallel;
  difftastic = channels.nixpkgs-unstable.difftastic;
  clang-tools = channels.nixpkgs-unstable.llvmPackages_18.clang-tools;
  # lazyjj = channels.nixpkgs-unstable.lazyjj.overrideAttrs (old: rec {
  #   src = self.fetchFromGitHub {
  #     owner = "expipiplus1";
  #     repo = "lazyjj";
  #     rev = "push-zxkwmuvpvxoq";
  #     sha256 = "sha256-JQUJZMLx6I8EDMObTevKbULjGrW9N2qt83KScMlmBXs=";
  #   };
  #   cargoDeps = old.cargoDeps.overrideAttrs (oldCargoDeps: {
  #     inherit src;
  #     outputHashMode = "recursive";
  #     outputHash = "sha256-flfFFqTZRmgLgekKRAstaKJJYRSeKoGRwBusb1wUt0I=";
  #   });
  #   doCheck = false;
  # });
  lazyjj = channels.nixpkgs-unstable.lazyjj.overrideAttrs (old: rec {
    src = self.fetchFromGitHub {
      owner = "expipiplus1";
      repo = "lazyjj";
      rev = "push-zxkwmuvpvxoq";
      hash = "sha256-Gu9F8XaDnzwSNpduihf8inSq9VSo48giGLknfEBh41Y=";
    };

    cargoDeps = self.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-PCJqfX+rEvPybZw3HlInrTr/w3XJe6EelZdmPnZYy1g=";
    };

    doCheck = false;
  });

  jujutsu = super.symlinkJoin {
    name = "jujutsu";
    paths = [ channels.nixpkgs-unstable.jujutsu ];
    buildInputs = [ self.makeWrapper ];
    postBuild = ''
      rm $out/bin/jj
      substitute ${./jj-wrapper.sh} $out/bin/jj \
        --replace '@jj_binary@' ${channels.nixpkgs-unstable.jujutsu}/bin/jj
      chmod +x $out/bin/jj
    '';
  };

  carapace = channels.nixpkgs-unstable.carapace;

  # fzf = super.fzf.overrideAttrs (old: {
  #   patches = old.patches or [ ] ++ [ ../patches/fzf-tmux.patch ];
  # });
  # direnv = super.direnv.overrideAttrs (old: {
  #   patches = old.patches or [ ] ++ [ ../patches/quiet-direnv.patch ];
  # });
  atuin = super.atuin.overrideAttrs (old: rec {
    patches = old.patches or [ ] ++ [ ../patches/atuin-popup.patch ];
  });
  memtest86plus = self.callPackage ({ stdenv, fetchurl, lib, }:
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

  # starship = super.starship.override {
  #   rustPlatform = self.rustPlatform // {
  #     buildRustPackage = args:
  #       self.rustPlatform.buildRustPackage (args // {
  #         src = self.fetchFromGitHub {
  #           owner = "idursun";
  #           repo = "starship";
  #           rev = "7226aaedf2dd0dd34a7373859d25da45c7cd3eaa";
  #           sha256 = "sha256-m0eA4Kv5RikMcnYqRlGnyHV1bQS3kDgHhGYGqTvbZBE=";
  #         };
  #         cargoHash = "sha256-d6i9+gnkt4wXzqB8+eLofX4enejG/YYiJAtg7KimA6M=";
  #       });
  #   };
  # };

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
