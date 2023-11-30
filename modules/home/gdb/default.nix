{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "gdb" {
  xdg.configFile = {
    "gdb/gdbinit".source = pkgs.writeTextFile {
      name = "gdbinit";
      text = ''
        set history save on
        set disassembly-flavor intel
        set debuginfod enabled on
      '';
    };
  };
}
