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
}
