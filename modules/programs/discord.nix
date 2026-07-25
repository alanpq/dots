{
  flake.modules.hjem.discord = {pkgs, ...}: {
    packages = [pkgs.discord pkgs.vesktop];
  };
}
