{ lib, config, inputs, system, pkgs, ... }@args:

let
  comfyui = inputs.comfyui-nix.packages.${system}.cuda;
in with args.lib; {
  options.ellie.comfyui = {
    enable = mkEnableOption "the comfyui module";
  };

  config = mkIf config.ellie.comfyui.enable {
    systemd.services.comfyui = {
      description = "ComfyUI";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        HOME = "/var/lib/comfyui";
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${comfyui}/bin/comfyui --listen 127.0.0.1 --port 8188 --base-directory /var/lib/comfyui --enable-manager";
        Restart = "on-failure";
        RestartSec = 5;
        StateDirectory = "comfyui";
        DynamicUser = true;
        # GPU access
        SupplementaryGroups = [ "video" "render" ];
        DeviceAllow = [
          "/dev/nvidia0 rw"
          "/dev/nvidiactl rw"
          "/dev/nvidia-uvm rw"
          "/dev/nvidia-uvm-tools rw"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 8188 ];
  };
}
