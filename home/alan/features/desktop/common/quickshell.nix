{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../common/matugen
  ];
  home.packages = with pkgs; [
    kdePackages.qtpositioning
    kdePackages.qt5compat
    libsForQt5.qt5.qtgraphicaleffects

    #kdePackages.breeze

    darkly
  ];
  programs.quickshell = {
    enable = true;
    package = inputs.quickshell.packages.${pkgs.stdenv.system}.default;
  };
}
