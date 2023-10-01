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
    impermanence = { url = "github:nix-community/impermanence"; };
    # lian-li-pump-control = { url = "github:expipiplus1/lian-li-pump-control"; };
    lian-li-pump-control = {
      url = "git:file:///home/e/projects/galahad-hs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, hm, nixseparatedebuginfod
    , impermanence, lian-li-pump-control }@inputs: {
      nixosConfigurations = {
        sophie = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [ ./hosts/sophie nixseparatedebuginfod.nixosModules.default ];
        };
        light-hope = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/light-hope
            nixseparatedebuginfod.nixosModules.default
            impermanence.nixosModule
            lian-li-pump-control.nixosModules.default
          ];
        };
        historian-bow = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/historian-bow ];
        };
      };

      homeConfigurations = {
        "e@light-hope" = hm.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            pkgs-stable = import nixpkgs-stable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          modules = [ ./home/home.nix ];
        };
        "e@sophie" = hm.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            pkgs-stable = import nixpkgs-stable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          modules = [ ./home/home.nix ];
        };
      };
    };
}
