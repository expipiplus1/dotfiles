{ config, pkgs, ... }:

{
  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;

  # Keep programs alive after logout (for example, tmux)
  services.logind.killUserProcesses = false;

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
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFErWB61gZadEEFteZYWZm8QRwabpl4kDHXsm0/rsLqoyWJN5Y4zF4kowSGyf92LfJu9zNBs2viuT3vmsLfg6r4wkbVyujpEo3JLuV79r9K8LcM32wA52MvQYATEzxuamZPZCBT9fI/2M6bC9lz67RQ5IoENfjZVCstOegSmODmOvGUs6JjrB40slB+4YXCVFypYq3uTyejaBMtKdu1S4TWUP8WRy8cWYmCt1+a6ACV2yJcwnhSoU2+QKt14R4XZ4QBSk4hFgiw64Bb3WVQlfQjz3qA4j5Tc8P3PESKJcKW/+AsavN1I2FzdiX1CGo2OL7p9TcZjftoi5gpbmzRX05 j@riza"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQChHW69/lghzz2b6T8hj6cShYGGDNA7g+HhS+P7JAWT43NiCvM+0S3xYr0sY/MNBqTHIV/5e2prP4uaCq7uyNT/5s8LLm6at8dhrKN1RZWQpHD9FID5sgw4yv8HANyVpt1+zY6PoqmhAb+Bj/g/H3Ijb+AAWbvWKxUMoChC9nWd5G+ogPpPQmElg/aGxjAL0oSuwGHEO1wNvV4/ddKLEWiLNF8Xdc0s4QkQnJZhyZMa+oaerI4wF7GqsVzsYg4ppK6YbZt5rv41XCqKp889b2JZphRVlN7LvJxX11ttctxFvhSlqa+C/7QvoFiOo5wJxZrwH3P1rMRfIWwzYas/sWlx jophish@cardassia.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGieLCIaLlzqPSZpa8e1SIHm9DVb97SKzzfg6mwvQdz4 e@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBML4JuxphjzZ/gKVLRAunKfTuFT6VVr6DfXduvsiHz j@orion"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBI9bd3ChEQDikNy0g9myDQlkzZxl8zcFfb5qhjn9NomNX3PV7G3dWVy8X5/rppkeRTYg7InkYTOU9tPjdhQ3mTk= ellie@ipad"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKz02gCLJO1cX7xLRtxdAajMGHSG4uaCPEZNr68/aNlWdUqIoJrwye0ngZFH1XakGrcwnHKowVtGItC4gpBOrrE= ellie@ipad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8wDcEeHIfK63eMWC3pXRmX1DpItY3+cpS0C2fmYc31 e@light-hope"
    ];
  };
}

