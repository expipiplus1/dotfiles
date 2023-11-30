{ lib, inputs, snowfall-inputs }: {
  simpleModule = inputs: name: config:
    let prefix = "ellie";
    in with inputs.lib; {
      options.${prefix}.${name} = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
      };

      config = mkIf inputs.config.${prefix}.${name}.enable config;
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
