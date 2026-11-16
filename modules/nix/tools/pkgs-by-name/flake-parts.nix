{
  inputs,
  withSystem,
  ...
}: {
  flake-file.inputs = {
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    packages = {
      url = "path:./packages";
      flake = false;
    };
  };

  imports = [
    inputs.pkgs-by-name-for-flake-parts.flakeModule
  ];

  perSystem = {system, ...}: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgsDirectory = inputs.packages;
  };

  flake = {
    overlays.default = _final: prev: {
      local = withSystem prev.stdenv.hostPlatform.system ({config, ...}: config.packages);
    };
  };
}
