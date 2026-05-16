{ channels, inputs, ... }:

self: super:
let
  pkgsCuda = import inputs.nixpkgs-unstable {
    localSystem = super.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      cudaSupport = true;
      cudaCapabilities = [ "8.9" ];
      cudaForwardCompat = false;
    };
  };
in {
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
  claude-agent-acp = channels.nixpkgs-unstable.claude-agent-acp;
  neovim = channels.nixpkgs-unstable.neovim;
  neovim-unwrapped = channels.nixpkgs-unstable.neovim-unwrapped;

  code-cursor = channels.nixpkgs-unstable.code-cursor;
  cursor-cli = channels.nixpkgs-unstable.cursor-cli;

  # Wrap claude-code to disable Statsig telemetry. Without this, each running
  # `claude` process polls statsig.anthropic.com on a short interval; with many
  # concurrent sessions this trips Pi-hole's per-client rate limit and causes
  # transient DNS failures across the whole host.
  claude-code = super.symlinkJoin {
    name = "claude-code";
    paths = [ channels.nixpkgs-claude.claude-code ];
    nativeBuildInputs = [ self.makeWrapper ];
    postBuild = ''
      for bin in $out/bin/*; do
        if [ -L "$bin" ]; then
          target=$(readlink -f "$bin")
          rm "$bin"
          makeWrapper "$target" "$bin" \
            --set-default DISABLE_TELEMETRY 1 \
            --set-default CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC 1
        fi
      done
    '';
  };

  rust-parallel = channels.nixpkgs-unstable.rust-parallel;
  difftastic = channels.nixpkgs-unstable.difftastic;

  blazingjj = channels.nixpkgs-unstable.lazyjj.overrideAttrs (old: rec {
    pname = "blazingjj";
    version = "0.7.1";
    src = self.fetchFromGitHub {
      owner = "blazingjj";
      repo = "blazingjj";
      rev = "d2f16e4dde33a3a3c2f8bc30ee68b18650edb317";
      hash = "sha256-oVUlwIgR5rKjO6QUhubUqmbDNjIGhZlfKuqRpDqLcOA=";
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

  darktable = channels.nixpkgs-unstable.darktable.overrideAttrs (old: {
    version = "master";
    src = self.fetchgit {
      url = "https://github.com/darktable-org/darktable";
      rev = "c8e6954c2be1578098096e911843793abd2b5ede";
      hash = "sha256-qxn8KsuLST7MGuoWkljqHiRrSNVaQxhNk4e9MqlBaME=";
      fetchSubmodules = true;
      deepClone = true;
    };
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ self.git ];
    buildInputs = (old.buildInputs or [ ])
      ++ [ pkgsCuda.onnxruntime self.potrace self.xz self.libarchive ];
    patches = (old.patches or [ ]) ++ [
      ../patches/darktable-ilce-7m5.patch
      ../patches/darktable-ilce-7m5-noiseprofile.patch
    ];
    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      # CPU-portable optimizations. Per-host -march=native is layered on top
      # in the host config (see systems/x86_64-linux/light-hope/default.nix).
      "-DCMAKE_BUILD_TYPE=Release"
      "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON"
      # Default to a generic build; hosts that want -march=native flip this
      # to OFF in their own overlay.
      "-DBINARY_PACKAGE_BUILD=ON"
      "-DCUSTOM_CFLAGS=OFF"
      "-DUSE_OPENCL=ON"
      "-DUSE_OPENMP=ON"
      "-DUSE_AI=ON"
    ];
    # darktable lazy-loads ONNX Runtime via g_module_open("libonnxruntime.so").
    # When built against a nix system package, CMake skips installing the .so
    # into lib/darktable/ and the nix store path isn't in the runtime linker
    # search path, so the dlopen fails. Symlink the libraries into the plugin
    # directory where darktable's fallback path looks.
    postInstall = (old.postInstall or "") + ''
      for lib in ${pkgsCuda.onnxruntime}/lib/libonnxruntime*.so*; do
        ln -sf "$lib" "$out/lib/darktable/$(basename "$lib")"
      done
    '';
    # git describe version won't match nixpkgs versionCheckHook.
    doInstallCheck = false;
  });

  carapace = channels.nixpkgs-unstable.carapace;

  dnsmasq = channels.nixpkgs-unstable.dnsmasq;

  lua51Packages = super.lua51Packages // {
    neotest =
      super.lua51Packages.neotest.overrideAttrs (_: { doCheck = false; });
  };

  # Pull the nvim-treesitter `main`-branch packaging from unstable so it works
  # with Neovim 0.12 / AstroNvim v6. The archived `master` branch shipped in
  # 25.11 is incompatible with Neovim 0.12's `iter_matches` API change.
  vimPlugins = super.vimPlugins // {
    nvim-treesitter = channels.nixpkgs-unstable.vimPlugins.nvim-treesitter;
    nvim-treesitter-textobjects =
      channels.nixpkgs-unstable.vimPlugins.nvim-treesitter-textobjects;
  };

}
