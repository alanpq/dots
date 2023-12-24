{ pkgs, ... }: {
  imports = [
    ./nextcloud-pwd.nix
  ];
  home.packages = with pkgs; [
    keepassxc # password manager
  ];
}
