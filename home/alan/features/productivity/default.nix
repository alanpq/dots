{pkgs, ...}: {
  imports = [
    ./nextcloud-pwd.nix
    ./keepassxc.nix
    ./obsidian.nix
    ./mail.nix
  ];

  home.packages = with pkgs; [
    qalculate-gtk
  ];
}
