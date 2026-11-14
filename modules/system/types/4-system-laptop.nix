{inputs, ...}: {
  flake.modules.nixos.system-laptop = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      greetd

      pipewire

      firefox
      steam

      theme

      niri

      thunar
    ];

    services.upower.enable = true;
  };

  flake.modules.hjem.system-laptop = {
    imports = with inputs.self.modules.hjem; [
      system-cli
      desktop

      theme
      vicinae

      quickshell

      niri
    ];
  };
}
