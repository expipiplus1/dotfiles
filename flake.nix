{
  inputs = {
    lix = {
      url =
        "git+https://git@git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixseparatedebuginfod = {
      url = "github:symphorien/nixseparatedebuginfod";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = { url = "github:nix-community/impermanence"; };
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
      inputs.flake-utils-plus.url = "github:fl42v/flake-utils-plus";
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
      overlays = with inputs; [ nil.overlays.default ];
      systems.modules.nixos = with inputs; [
        # nixseparatedebuginfod.nixosModules.default
        impermanence.nixosModule
        lian-li-control.nixosModules.fan
        lian-li-control.nixosModules.pump
        nixos-wsl.nixosModules.default
        lix-module.nixosModules.default
      ];
      # This seems to pull them in for nixos builds too?
      # homes.modules = with inputs;
      #   [ plasma-manager.homeManagerModules.plasma-manager ];

      homes.users."e@light-hope".modules = with inputs;
        [ plasma-manager.homeManagerModules.plasma-manager ];
      homes.users."e@sophie".modules = with inputs;
        [ plasma-manager.homeManagerModules.plasma-manager ];
      homes.users."e@howl".modules = with inputs;
        [ plasma-manager.homeManagerModules.plasma-manager ];
    };
}
