{ config, pkgs, ... }:

let
  importYaml = file:
    builtins.fromJSON (builtins.readFile
      (pkgs.runCommandNoCC "converted-yaml.json"
        ''${pkgs.yj}/bin/yj < "${file}" > "$out"''));

  readYaml = path:
    with pkgs;
    let
      jsonOutputDrv =
        runCommand "from-yaml" { nativeBuildInputs = [ remarshal ]; }
        ''remarshal -if yaml -i "${path}" -of json -o "$out"'';
    in builtins.fromJSON (builtins.readFile jsonOutputDrv);

in {
  programs.alacritty = {
    enable = true;
    settings = {
      draw_bold_text_with_bright_colors = false;
      window.dimensions = {
        lines = 84;
        columns = 295;
      };
      font = {
        size = 8;
      } // pkgs.lib.mapAttrs (name: value: {
        family = "Iosevka Term";
        # or family = "DejaVu Sans Mono";
        style = value;
      }) {
        normal = "Regular";
        bold = "Semibold";
        italic = "Italic";
        bold_italic = "Semibold Italic";
      };
    } // (readYaml (builtins.fetchurl {
      url =
        "https://raw.githubusercontent.com/nordtheme/alacritty/main/src/nord.yaml";
      sha256 = "1sgq1d7w97wj1pw89mlbf3gz2idxvfs2xyg7rhwb1jgl50yr29ks";
    }));
  };
}
