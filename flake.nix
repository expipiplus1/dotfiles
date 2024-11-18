{
  inputs = {
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixseparatedebuginfod = {
      url = "github:symphorien/nixseparatedebuginfod";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      # https://github.com/nix-community/impermanence/issues/215#issuecomment-2370010816
      url =
        "github:nix-community/impermanence/63f4d0443e32b0dd7189001ee1894066765d18a5";
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
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      channels-config = { allowUnfree = true; };
      overlays = with inputs; [
        nil.overlays.default
        lix-module.overlays.default
      ];
      systems.modules.nixos = with inputs; [
        # nixseparatedebuginfod.nixosModules.default
        impermanence.nixosModule
        lian-li-control.nixosModules.fan
        lian-li-control.nixosModules.pump
        nixos-wsl.nixosModules.default
      ];
      # This seems to pull them in for nixos builds too?
      homes.modules = with inputs;
        [ plasma-manager.homeManagerModules.plasma-manager ];
      homes.users."nixos@nixos".modules = with inputs;
        [ plasma-manager.homeManagerModules.plasma-manager ];
    };
}
