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

      walker
      
      thunar
    ];
  };

  flake.modules.hjem.system-laptop = {
    imports = with inputs.self.modules.hjem; [
      system-cli
      desktop

      vicinae
      walker

      niri
    ];
  };
}
