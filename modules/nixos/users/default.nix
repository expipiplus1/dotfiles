{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "users" {
  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;

  # Keep programs alive after logout (for example, tmux)
  services.logind.killUserProcesses = false;

  home-manager.users = lib.mkForce { };
  users.users.e = {
    isNormalUser = true;
    description = "Ellie Hermaszewska";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "bluetooth"
      "vboxusers"
      "dialout"
      "networkmanager"
      "wireshark"
      "video"
    ];
    subUidRanges = [{
      startUid = 100000;
      count = 65536;
    }];
    subGidRanges = [{
      startGid = 100000;
      count = 65536;
    }];
    hashedPassword =
      "$6$leXV9Uwdw1JP5z$yCxKu/YvrhT7iqGgGU//sv4RYOp6zC797nlRWmSM9L0Fy3GYN94i4QoY8k8jJ9He1PGfeXp4vtX006INgXMY/1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8wDcEeHIfK63eMWC3pXRmX1DpItY3+cpS0C2fmYc31 e@light-hope"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQmXJqBBEabFL7npxcBGCroPedjUcGe3hl9wBgMtCT2 e@thanos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzfehGlktzfIvfE5RtfFCR822QvYdPAzflZhgx0K50m ellieh@nvidia.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPalnsykM5Suo+0eLLkPCNGZJxgVLivIPKa4fQRZwe2H ellieh@ellieh-mlt"
    ];
  };
}
