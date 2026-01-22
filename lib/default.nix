{ lib, inputs, snowfall-inputs }: {
  simpleModule = inputs: name: config:
    let
      prefix = "ellie";
      imports = config.imports or [ ];
      configWithoutImports = builtins.removeAttrs config [ "imports" ];
    in with inputs.lib; {
      inherit imports;
      options.${prefix}.${name} = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
      };

      config = mkIf inputs.config.${prefix}.${name}.enable configWithoutImports;
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
