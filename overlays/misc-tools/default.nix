{ ... }:
self: super: {
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

  gersemi = self.python3Packages.buildPythonApplication rec {
    pname = "gersemi";
    version = "0.9.3";
    src = self.fetchPypi {
      inherit pname version;
      sha256 = "sha256-fNhmq9KKOwlc50iDEd9pqHCM0br9Yt+nKtrsoS1d5ng=";
    };
    doCheck = false;
    propagatedBuildInputs = [
      self.python3Packages.appdirs
      self.python3Packages.lark
      self.python3Packages.pyyaml
    ];
  };

  cmake-language-server = super.cmake-language-server.overrideAttrs (old: {
    src = self.fetchFromGitHub {
      owner = "expipiplus1";
      repo = "cmake-language-server";
      rev = "94e60dfa56341fca4289ea188d8e8dda90ae5f4c";
      sha256 = "sha256-kPKeW/jCeAbiKJTb+gTo7qG8qLC2k9grGTyWz63IqFM=";
    };
  });
}
