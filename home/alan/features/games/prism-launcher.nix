{
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.prismlauncher];

  # home.persistence = {
  #   "/persist/home/alan".directories = [".local/share/PrismLauncher"];
  # };
}
