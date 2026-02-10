{ inputs, ... }:
self: super:
let
  # Use unstable nixpkgs for Python packages that need newer versions
  pkgsUnstable = import inputs.nixpkgs-unstable { inherit (super) system; };
  python = pkgsUnstable.python311;

  claude-agent-sdk = python.pkgs.buildPythonPackage rec {
    pname = "claude-agent-sdk";
    version = "0.1.34";
    format = "wheel";

    src = super.fetchurl {
      url = "https://files.pythonhosted.org/packages/py3/c/claude_agent_sdk/claude_agent_sdk-${version}-py3-none-manylinux_2_17_x86_64.whl";
      sha256 = "sha256-gukUhBDsmP9AYeQ+hWAdjwouhWjYl6uCwyTM8Rwpf8U=";
    };

    nativeBuildInputs = [ super.autoPatchelfHook ];
    buildInputs = [ super.stdenv.cc.cc.lib super.zlib super.glibc ];
    propagatedBuildInputs = with python.pkgs; [ anyio mcp typing-extensions ];
    autoPatchelfIgnoreMissingDeps = [ "libnode.so*" ];
    pythonImportsCheck = [ "claude_agent_sdk" ];
  };

  claude-wrapper-src = super.fetchFromGitHub {
    owner = "RichardAtCT";
    repo = "claude-code-openai-wrapper";
    rev = "f6994d0839f96a73600ef3353231b3afefd384ee";
    hash = "sha256-++sK/6Gg/HJjDHFbrQnywNUbNdazXHdlSN6xV1MDg8I=";
  };

  claude-wrapper = python.pkgs.buildPythonApplication {
    pname = "claude-code-openai-wrapper";
    version = "2.2.0";
    pyproject = true;
    src = claude-wrapper-src;
    patches = [ ../patches/claude-code-openai-wrapper.patch ];

    nativeBuildInputs = with python.pkgs; [
      poetry-core
      pythonRelaxDepsHook
      super.makeBinaryWrapper
    ];

    propagatedBuildInputs = with python.pkgs; [
      fastapi
      uvicorn
      pydantic
      python-dotenv
      httpx
      sse-starlette
      python-multipart
      slowapi
      claude-agent-sdk
    ];

    doCheck = false;
    pythonRelaxDeps = true;

    makeWrapperArgs = [ "--prefix PATH : ${super.nodejs_20}/bin" ];
  };
in
{
  claude-server = super.writeShellScriptBin "claude-server" ''
    export CLAUDE_CLI_PATH="$(which claude)"
    echo n | exec ${claude-wrapper}/bin/claude-wrapper "$@"
  '';
  ymlfmt = self.stdenv.mkDerivation {
    name = "ymlfmt";
    buildInputs = [
      (self.python3.withPackages
        (pythonPackages: with pythonPackages; [ ruamel_yaml ]))
    ];
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      cat > "$out/bin/ymlfmt" << EOF
      #!/usr/bin/env python
      import sys
      from ruamel import yaml
      yaml.round_trip_dump(yaml.round_trip_load(sys.stdin), sys.stdout)
      EOF
      chmod +x "$out/bin/ymlfmt"
    '';
  };

  json2nix = self.writeScriptBin "json2nix" ''
    ${self.python3}/bin/python ${
      self.fetchurl {
        url =
          "https://gist.githubusercontent.com/Scoder12/0538252ed4b82d65e59115075369d34d/raw/e86d1d64d1373a497118beb1259dab149cea951d/json2nix.py";
        hash = "sha256-ROUIrOrY9Mp1F3m+bVaT+m8ASh2Bgz8VrPyyrQf9UNQ=";
      }
    } $@
  '';

  cmake-language-server = super.cmake-language-server.overrideAttrs (old: {
    pytestCheckPhase = ":";
    checkPhase = ":";
    src = self.fetchFromGitHub {
      owner = "expipiplus1";
      repo = "cmake-language-server";
      rev = "e142bf9e396c0cc23c3ac7c053a2d9e3661df619"; # format
      sha256 = "1mvri61l0wvj8sww3v4sgvf2w0qgxq1ywc28fm6b1ww00ipmf0im";
    };
  });
}
