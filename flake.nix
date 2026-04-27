{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-claude.url = "github:expipiplus1/nixpkgs/claude-code-2.0.58-or-fix";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      # https://github.com/nix-community/impermanence/issues/215#issuecomment-2370010816
      url = "github:nix-community/impermanence";
    };
    lian-li-control = {
      url = "github:expipiplus1/lian-li-control";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    japan-transfer = {
      url = "git+ssh://git@github.com/expipiplus1/japan-transfer";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    kanji-explorer = {
      url = "git+ssh://git@github.com/expipiplus1/kanji-explorer";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    anki-progress = {
      url = "git+ssh://git@github.com/expipiplus1/anki-progress";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    ug-proxy = {
      url = "path:/home/e/projects/ultimate-guitar";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      channels-config = {
        allowUnfree = true;
      };
      systems.modules.nixos = with inputs; [
        impermanence.nixosModule
        lian-li-control.nixosModules.fan
        lian-li-control.nixosModules.pump
        nixos-wsl.nixosModules.default
        japan-transfer.nixosModules.default
        kanji-explorer.nixosModules.default
        anki-progress.nixosModules.default
        ug-proxy.nixosModules.default
      ];
      # This seems to pull them in for nixos builds too?
      homes.modules = with inputs; [
        plasma-manager.homeModules.plasma-manager
        anki-progress.homeManagerModules.default
      ];
    };
}
