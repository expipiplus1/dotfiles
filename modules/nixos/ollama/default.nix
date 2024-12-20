{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "ollama" {
  services.ollama = {
    enable = true;
    acceleration = "cuda";
  };
}
