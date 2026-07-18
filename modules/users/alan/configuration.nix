{
  inputs,
  self,
  ...
}: let
  username = "alan";
in {
  flake.modules.nixos."${username}" = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
    ];

    users.users."${username}" = {
      isNormalUser = true;
      name = "${username}";
      shell = pkgs.zsh;

      password = "temp";
    };

    hjem.users."${username}" = {
      imports = [
        inputs.self.modules.hjem."${username}"
      ];
    };

    programs.zsh.enable = true;
  };
}
