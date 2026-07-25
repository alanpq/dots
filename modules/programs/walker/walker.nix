{inputs, ...}: {
  flake.modules.nixos.walker = {pkgs, ...}: let
    providers = [
      "bluetooth"
      "desktopapplications"
      "symbols"
      "calc"
      "unicode"
    ];
  in {
    imports = [inputs.walker.nixosModules.default];
    disabledModules = ["services/misc/elephant.nix"];

    programs.walker = {
      enable = true;

      elephant = {
        inherit providers;
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
