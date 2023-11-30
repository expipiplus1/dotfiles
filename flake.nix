{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-anki.url =
      "github:paveloom/nixpkgs/fa0ee9ec09f411fb4b04473150df9b28b039e76e";
    hm = {
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
      inputs.home-manager.follows = "hm";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, hm, nixseparatedebuginfod
    , impermanence, lian-li-control, plasma-manager, nil, nixpkgs-anki
    }@inputs: {
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
            lian-li-control.nixosModules.fan
            lian-li-control.nixosModules.pump
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
            inherit nil;
            pkgs-stable = import nixpkgs-stable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
            pkgs-anki = import nixpkgs-anki {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          modules = [
            ./home/home.nix
            plasma-manager.homeManagerModules.plasma-manager
          ];
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
