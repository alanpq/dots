{
  pkgs,
  config,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.mutableUsers = false;
  users.users.alan = {
    isNormalUser = true;
    extraGroups =
      [
        "wheel"
        "video"
        "audio"
      ]
      ++ ifTheyExist [
        "networkmanager"
        "minecraft"
        "network"
        "wireshark"
        "i2c"
        "mysql"
        "docker"
        "podman"
        "git"
        "libvirtd"
        "deluge"
      ];
    # hashedPasswordFile = config.sops.secrets.alan-password.path;
    password = "temp";
    packages = with pkgs; [
      home-manager
    ];
  };

  sops.secrets.alan-password = {
    sopsFile = ../../secrets.yaml;
    neededForUsers = true;
  };

  home-manager.users.alan = import ../../../../home/alan/${config.networking.hostName}.nix;

  services.geoclue2.enable = true;
}
