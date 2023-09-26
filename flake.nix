{
  description = "my dots :)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager }@inputs:
    {
      nixosConfigurations.zwei-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          { nixpkgs.overlays = builtins.attrValues self.overlays; }
          ./hosts/zwei-pc/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alan = import ./hosts/zwei-pc/home.nix;
          }
        ];
      };

      overlays = (import ./util.nix).mkOverlays self.packages;
    } // flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = builtins.attrValues self.overlays;
      };
      packages = # does this override consumers' setting or will it error later? also apparently precludes x-compile
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in {

        };
      formatter = nixpkgs.legacyPackages.${system}.nixfmt;
    });
}
