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
  neovim = channels.nixpkgs-unstable.neovim;
  neovim-unwrapped = channels.nixpkgs-unstable.neovim-unwrapped;

  code-cursor = channels.nixpkgs-unstable.code-cursor;
  cursor-cli = channels.nixpkgs-unstable.cursor-cli;
  claude-code = channels.nixpkgs-claude.claude-code;

  rust-parallel = channels.nixpkgs-unstable.rust-parallel;
  difftastic = channels.nixpkgs-unstable.difftastic;

  blazingjj = channels.nixpkgs-unstable.lazyjj.overrideAttrs (old: rec {
    pname = "blazingjj";
    version = "0.7.1";
    src = self.fetchFromGitHub {
      owner = "blazingjj";
      repo = "blazingjj";
      rev = "f0f28b3f8a8127e57585749405e70cb13eb34807";
      hash = "sha256-UkO4x2C+nTGZNcFiOyjaziRJT3h0W98H60Sjk1Wv4FY=";
    };

    cargoDeps = self.rustPlatform.fetchCargoVendor {
      inherit src;
      hash = "sha256-ysU4W9+BWuyTEHyiEUOttECAhGIjRyoRzzf8QbbwMuo=";
    };

    postInstall = ''
      wrapProgram $out/bin/blazingjj \
        --prefix PATH : ${self.jujutsu}/bin
    '';

    versionCheckProgram = "${placeholder "out"}/bin/blazingjj";

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

  lua51Packages = super.lua51Packages // {
    neotest = super.lua51Packages.neotest.overrideAttrs (_: {
      doCheck = false;
    });
  };

  atuin = super.atuin.overrideAttrs (old: rec {
    patches = old.patches or [ ] ++ [ ../patches/atuin-popup.patch ];
  });

  tree-sitter = super.tree-sitter.overrideAttrs (old: {
    passthru.buildGrammar =
      x:
      if x.language == "haskell" then
        old.passthru.buildGrammar (
          x
          // {
            src = self.fetchFromGitHub {
              owner = "tek";
              repo = "tree-sitter-haskell";
              sha256 = "0kpg1c87magrcgp365kmvnfjq9c0mlc81mx4vdz22p00jfynmin3";
              rev = "3a965b242b1a6553097b8c0d12c4989074d74b5f";
            };
            generate = true;
          }
        )
      else
        old.passthru.buildGrammar x;
  });
}
