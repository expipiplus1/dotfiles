{ lib, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "ollama" {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    loadModels = [ "qwen3.6:27b" ];
  };
}
