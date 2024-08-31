{pkgs, ...}: {
  imports = [
    ./lutris.nix
    ./steam.nix
    ./prism-launcher.nix
  ];
  home = {
    packages = with pkgs; [gamescope];
    # persistence = {
    #   "/persist/home/alan" = {
    #     allowOther = true;
    #     directories = [
    #       "Games"
    #     ];
    #   };
    # };
  };
}
