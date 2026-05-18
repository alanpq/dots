{
  pkgs,
  config,
  ...
}: {
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "adwaita-dark";
      # package = pkgs.qt6Packages.qt6gtk2;
    };
  };
}
