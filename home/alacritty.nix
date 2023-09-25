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
      window.decorations = "none";
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
        "https://raw.githubusercontent.com/nordtheme/alacritty/5b0a462df0f35192b315a1b2e5605e0a29c410ea/src/nord.yml";
      sha256 = "0vxryacz2zvp7kz3jy5fp7v0ild9wg64j619a5pvlbipb0vhb3xk";
    }));
  };
}
