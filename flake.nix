{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fu.url = "github:numtide/flake-utils";
    hm = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fu, hm }@inputs: {
    nixosConfigurations.sophie = nixpkgs.lib.nixosSystem {
      specialArgs = inputs;
      modules = [ (import ./hosts/sophie) ];
    };

    homeConfigurations = {
      "e@sophie" = hm.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg)
            [ "vscode-extension-ms-vscode-cpptools" ];
        };
        modules = [ ./home/home.nix ];
      };
    };
  };
}
