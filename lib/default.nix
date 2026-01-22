{ lib, inputs, snowfall-inputs }: {
  simpleModule = inputs: name: config:
    let
      prefix = "ellie";
      imports = config.imports or [ ];
      configWithoutImports = builtins.removeAttrs config [ "imports" ];
    in with inputs.lib; {
      inherit imports;
      options.${prefix}.${name} = {
        enable = mkEnableOption "the ${name} module";
      };

      config = mkIf inputs.config.${prefix}.${name}.enable configWithoutImports;
    };

  btrfs = {
    subvolOpts = subvol: [
      "subvol=${subvol}"
      "compress=zstd"
      "noatime"
      "discard=async"
    ];
  };

  appendPatches = patches: drv:
    drv.overrideAttrs (old: { patches = old.patches or [ ] ++ patches; });

  mergeBefore = x: xs: lib.mkMerge [ (lib.mkBefore [ x ]) xs ];

  nvim = {
    luaConfig = lua: ''
      lua <<EOF
      ${lua}
      EOF
    '';
  };
}
