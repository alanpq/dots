{inputs, ...}: {
  flake.modules.nixos.system-laptop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      greetd

      pipewire

      firefox
      steam

      stylix

      niri

      thunar
    ];
  };

  flake.modules.hjem.system-laptop = {
    imports = with inputs.self.modules.hjem; [
      system-cli
      desktop

      stylix

      vicinae

      quickshell

      niri
    ];
  };
}
