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
