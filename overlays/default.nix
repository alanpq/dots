{
  outputs,
  inputs,
}: let
  addPatches = pkg: patches:
    pkg.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ patches;
    });
in {
  # Third party overlays
  nh = inputs.nh.overlays.default;

  stable-replacements = final: prev: {
    swaylock-effects = inputs.nixpkgs-stable.legacyPackages.${prev.system}.swaylock-effects;
  };

  # For every flake input, aliases 'pkgs.inputs.${flake}' to
  # 'inputs.${flake}.packages.${pkgs.system}' or
  # 'inputs.${flake}.legacyPackages.${pkgs.system}'
  flake-inputs = final: _: {
    inputs =
      builtins.mapAttrs
      (
        _: flake: let
          legacyPackages = (flake.legacyPackages or {}).${final.system} or {};
          packages = (flake.packages or {}).${final.system} or {};
        in
          if legacyPackages != {}
          then legacyPackages
          else packages
      )
      inputs;
  };

  # Adds my custom packages
  additions = final: prev:
    import ../pkgs {pkgs = final;}
    // {
      formats = prev.formats // import ../pkgs/formats {pkgs = final;};
    };

  node-pkgs = final: prev: {
    myNodePkgs = final.callPackage ../pkgs/node/node-packages.nix {
      nodeEnv = final.callPackage ../pkgs/node/node-env.nix (with final; {
        inherit stdenv lib python2 runCommand writeTextFile writeShellScript;
        inherit nodejs;
        libtool =
          if stdenv.isDarwin
          then cctools or darwin.cctools
          else null;
      });
    };
  };

  # Modifies existing packages
  modifications = final: prev: {
    checkbashisms = prev.checkbashisms.overrideAttrs (old: let
      version = "2.25.15+deb13u1";
    in {
      inherit version;

      src = final.fetchFromGitLab {
        domain = "salsa.debian.org";
        owner = "debian";
        repo = "devscripts";
        tag = "v${version}";
        hash = "sha256-szyVLpeIQozPXwBgL4nIYog4znUzweIt8q7nczo5q+g=";
      };
    });

    debian-devscripts = prev.debian-devscripts.overrideAttrs (old: let
      version = "2.25.15+deb13u1";
    in {
      inherit version;
      src = final.fetchFromGitLab {
        domain = "salsa.debian.org";
        owner = "debian";
        repo = "devscripts";
        tag = "v${version}";
        hash = "sha256-szyVLpeIQozPXwBgL4nIYog4znUzweIt8q7nczo5q+g=";
      };
    });
    pfetch = prev.pfetch.overrideAttrs (oldAttrs: {
      version = "unstable-2021-12-10";
      src = final.fetchFromGitHub {
        owner = "dylanaraps";
        repo = "pfetch";
        rev = "a906ff89680c78cec9785f3ff49ca8b272a0f96b";
        sha256 = "sha256-9n5w93PnSxF53V12iRqLyj0hCrJ3jRibkw8VK3tFDvo=";
      };
      # Add term option, rename de to desktop, add scheme option
      patches = (oldAttrs.patches or []) ++ [./pfetch.patch];
    });
  };
}
