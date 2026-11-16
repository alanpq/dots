{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.workpad = {config, ...}: {
    imports = with inputs.self.modules.nixos; [
      alan
    ];
    hjem.users.alan = {
      imports = with inputs.self.modules.hjem; [
        system-laptop

        polkit-gnome
      ];
    };
  };
}
