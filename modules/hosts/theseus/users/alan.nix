{
  inputs,
  self,
  ...
}: {
  flake.modules.nixos.theseus = {
    config,
    pkgs,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [
      alan
    ];
    hjem.users.alan = {
      imports = with inputs.self.modules.hjem; [
        system-desktop
        discord
      ];

      packages = [pkgs.vscode];
    };
  };
}
