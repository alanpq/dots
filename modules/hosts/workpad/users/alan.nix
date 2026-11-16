{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.workpad = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      alan
    ];
    hjem.users.alan = {
      packages = with pkgs; [
        local.linear
      ];
      imports = with inputs.self.modules.hjem; [
        system-laptop

        discord

        polkit-gnome
      ];
    };
  };
}
