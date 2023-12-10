{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "dual-boot" {
  xdg.dataFile."applications/windows.desktop".source = pkgs.writeTextFile {
    name = "windows.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Boot To Windows
      Comment=Reboot into windows
      Exec=systemctl reboot --boot-loader-entry=auto-windows
      Terminal=false
      Hidden=false
    '';
  };
}
