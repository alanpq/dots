{
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    (pkgs.lutris.override {
      extraPkgs = p: [
        p.wineWowPackages.staging
        p.pixman
        p.libjpeg
        p.zenity
      ];
    })
  ];

  # home.persistence = {
  #   "/persist/home/alan" = {
  #     allowOther = true;
  #     directories = [
  #       ".config/lutris"
  #       ".local/share/lutris"
  #     ];
  #   };
  # };
}
