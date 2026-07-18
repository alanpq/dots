{inputs, ...}: {
  flake.modules.nixos.system-laptop = {
    imports = with inputs.self.modules.nixos; [
      system-cli

      wireless
    ];
  };

  flake.modules.hjem.system-laptop = {
    imports = with inputs.self.modules.homeManager; [
      system-cli
    ];
  };
}
