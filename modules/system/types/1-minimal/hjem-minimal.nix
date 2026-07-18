{inputs, ...}: {
  flake.modules.hjem.system-minimal = {
    config,
    pkgs,
    lib,
    ...
  }: {
    hjem = {
      extraModules = [
        inputs.hjem-rum.hjemModules.default
      ];
      clobberByDefault = true;
    };
  };
}
