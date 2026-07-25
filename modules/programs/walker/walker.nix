{inputs, ...}: {
  flake.modules.nixos.walker = {
    config,
    lib,
    ...
  }: let
    providers =
      [
        "desktopapplications"
        "calc"
        "symbols"
      ]
      ++ lib.lists.optionals config.hardware.bluetooth.enable ["bluetooth"]
      ++ lib.lists.optionals config.programs.niri.enable ["niriactions" "nirisessions"];
  in {
    imports = [inputs.walker.nixosModules.default];
    disabledModules = ["services/misc/elephant.nix"];

    programs.walker = {
      enable = true;

      elephant = {
        inherit providers;
        provider = {
        };
      };

      config = {
        placeholders."default" = {
          input = "Search";
          list = "No results.";
        };
        providers.default = providers;
        keybinds.quick_activate = ["F1" "F2" "F3" "F4"];
      };
    };
  };
}
