{inputs, ...}: let
  username = "alan";
in {
  flake.modules.nixos."${username}" = {
    pkgs,
    config,
    ...
  }: let
    ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  in {
    imports = with inputs.self.modules.nixos; [
    ];

    users.users."${username}" = {
      isNormalUser = true;
      name = "${username}";
      shell = pkgs.zsh;

      password = "temp";

      extraGroups =
        ["wheel"]
        ++ ifTheyExist [
          "video"
          "audio"

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
    };

    hjem.users."${username}" = {
      imports = [
        inputs.self.modules.hjem."${username}"
      ];
    };

    programs.zsh.enable = true;
  };
}
