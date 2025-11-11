{pkgs, ...}: {
  programs.walker = {
    enable = true;
    runAsService = true;

    # All options from the config.toml can be used here.
    config = {
      force_keyboard_focus = true;
      placeholders."default".input = "Example";
      keybinds.quick_activate = ["F1" "F2" "F3"];
    };

    elephant = {
      providers = [
        "bluetooth"
        "desktopapplications"
        "symbols"
        "calc"
        "unicode"
      ];
    };

    # If this is not set the default styling is used.
    # theme.style = ''
    #   * {
    #     color: #dcd7ba;
    #   }
    # '';
  };
}
