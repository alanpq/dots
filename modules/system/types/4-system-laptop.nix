{inputs, ...}: {
  flake.modules.nixos.system-laptop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      greetd

      niri

      wireless
    ];
  };

  flake.modules.hjem.system-laptop = {
    imports = with inputs.self.modules.hjem; [
      system-cli

      niri
    ];
  };
}
