{inputs, ...}: {
  flake.modules.nixos.walker = {pkgs, ...}: let
    providers = [
      "bluetooth"
      "desktopapplications"
      "calc"
      "symbols"
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
        providers.default = ["desktopapplications" "calc" "symbols"];
        keybinds.quick_activate = ["F1" "F2" "F3" "F4"];
      };
    };
  };
}
