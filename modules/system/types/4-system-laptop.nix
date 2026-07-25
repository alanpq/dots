{inputs, ...}: {
  flake.modules.nixos.system-laptop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      greetd

      pipewire
      bluetooth

      firefox
      steam

      niri
      walker
      thunar

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
