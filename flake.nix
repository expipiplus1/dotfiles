{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    fu.url = "github:numtide/flake-utils";
    hm = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, fu, hm }@inputs: {
    nixosConfigurations.sophie = nixpkgs-stable.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ (import ./hosts/sophie) ];
    };

    homeConfigurations = {
      "e@sophie" = hm.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [ ./home/home.nix ];
      };
    };
  };
}
