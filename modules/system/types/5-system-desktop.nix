{inputs, ...}: {
  flake.modules.nixos.system-desktop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      greetd

      niri
    ];
  };

  flake.modules.hjem.system-desktop = {
    imports = with inputs.self.modules.hjem; [
      system-cli

      niri
    ];
  };
}
