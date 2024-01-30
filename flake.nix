{
  description = "my dots :)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrix.url = "github:Platonic-Systems/secrix";

    nix-gaming.url = "github:fufexan/nix-gaming";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, secrix, nix-gaming }@inputs:
    {
      nixosConfigurations.zwei-pc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          { nixpkgs.overlays = builtins.attrValues self.overlays; }
          ./hosts/zwei-pc/configuration.nix
          home-manager.nixosModules.home-manager
          {

            home-manager.extraSpecialArgs = inputs;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alan = import ./hosts/zwei-pc/home.nix;
          }
        ];
      };

      overlays = (import ./util.nix).mkOverlays self.packages;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        legacyPackages = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = builtins.attrValues self.overlays;
        };
        apps = {
          secrix = inputs.secrix.secrix self;
        };
        devShell = with pkgs; mkShell {
          buildInputs = [ lua-language-server lua ];
        };
        packages = # does this override consumers' setting or will it error later? also apparently precludes x-compile
          {
            fluent-kv = pkgs.callPackage ./pkgs/fluent.nix { };
            postman = pkgs.callPackage ./pkgs/postman/default.nix { };
            discord-screenaudio = pkgs.libsForQt5.callPackage ./pkgs/discord-screenaudio.nix { };
          };
        formatter = nixpkgs.legacyPackages.${system}.nixfmt;
      });
}
