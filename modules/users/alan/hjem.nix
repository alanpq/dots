{inputs, ...}: let
  username = "alan";
in {
  flake.modules.hjem."${username}" = {pkgs, ...}: {
    imports = with inputs.self.modules.hjem; [
      system-laptop
      # messaging
    ];
    user = "${username}";
    directory = "/home/${username}";
  };
}
