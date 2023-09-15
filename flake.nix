{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    hm = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixseparatedebuginfod = {
      url = "github:symphorien/nixseparatedebuginfod";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, nixpkgs-stable, hm, nixseparatedebuginfod }@inputs: {
      nixosConfigurations = with nixpkgs-stable.lib; {
        sophie = nixosSystem {
          system = "x86_64-linux";
          modules =
            [ ./hosts/sophie nixseparatedebuginfod.nixosModules.default ];
        };
        historian-bow = nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/historian-bow ];
        };
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
