{
  description = "my dots :)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    nix-colors.url = "github:misterio77/nix-colors";

    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-gaming = {
    #   url = "github:fufexan/nix-gaming";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprwm-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
    };

    hyprspace = {
      url = "github:hyprspace/hyprspace";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs"; # override this repo's nixpkgs snapshot
    };

    sherlock = {
      url = "github:Skxxtz/sherlock";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant.url = "github:abenz1267/elephant";
    walker.url = "github:abenz1267/walker";
    walker.inputs.elephant.follows = "elephant";

    neovim = {
      url = "github:alanpq/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alanp-web = {
      url = "github:alanpq/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    heardle = {
      url = "git+ssh://git@github.com/alanpq/heardle/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    disko,
    home-manager,
    ...
  } @ inputs: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;
    systems = ["x86_64-linux" "aarch64-linux"];
    forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs systems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    inherit lib;
    nixosModules = import ./modules/nixos;
    homeManagerModules = import ./modules/home-manager;
    # templates = import ./templates;

    overlays = import ./overlays {inherit inputs outputs;};
    # hydraJobs = import ./hydra.nix { inherit inputs outputs; };

    packages = forEachSystem (pkgs: import ./pkgs {inherit pkgs;});
    devShells = forEachSystem (pkgs: import ./shell.nix {inherit pkgs;});
    formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

    wallpapers = import ./home/alan/wallpapers;

    nixosConfigurations = {
      # Main desktop
      zwei-pc = lib.nixosSystem {
        modules = [./hosts/zwei-pc];
        specialArgs = {inherit inputs outputs;};
      };
      # Laptop
      gamer-think = lib.nixosSystem {
        modules = [./hosts/gamer-think];
        specialArgs = {inherit inputs outputs;};
      };

      # Hetzner VPS
      zephyr = lib.nixosSystem {
        modules = [disko.nixosModules.disko ./hosts/zephyr];
        specialArgs = {inherit inputs outputs;};
      };

      live-usb = lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./hosts/live-usb];
        specialArgs = {inherit inputs outputs;};
      };
    };

    homeConfigurations = {
      "alan@zwei-pc" = lib.homeManagerConfiguration {
        modules = [./home/alan/zwei-pc.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "alan@gamer-think" = lib.homeManagerConfiguration {
        modules = [./home/alan/gamer-think.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      "alan@live-usb" = lib.homeManagerConfiguration {
        modules = [./home/alan/live-usb.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
    };
  };
}
