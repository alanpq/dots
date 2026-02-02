{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ../../matugen
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
    systemd.enable = true;
    package = inputs.quickshell.packages.${pkgs.stdenv.system}.default;
  };
  xdg.configFile."quickshell" = {
    source = ./config;
    recursive = true;
  };
}
