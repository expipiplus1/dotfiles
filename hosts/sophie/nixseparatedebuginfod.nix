{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs;
    [ (lib.getBin (pkgs.elfutils.override { enableDebuginfod = true; })) ];
  services.nixseparatedebuginfod.enable = true;
}

