{pkgs, ...}: {
  programs.walker = let
    providers = [
      "bluetooth"
      "desktopapplications"
      "symbols"
      "calc"
      "unicode"
    ];
  in {
    enable = true;
    runAsService = true;

    # All options from the config.toml can be used here.
    config = {
      force_keyboard_focus = true;
      placeholders."default" = {
        input = "Search";
        list = "No results.";
      };
      providers.default = ["bluetooth" "desktopapplications" "calc" "runner" "websearch"];
      keybinds.quick_activate = ["F1" "F2" "F3" "F4"];
    };

    elephant = {
      inherit providers;
    };

    # If this is not set the default styling is used.
    # theme.style = ''
    #   * {
    #     color: #dcd7ba;
    #   }
    # '';
  };
}
