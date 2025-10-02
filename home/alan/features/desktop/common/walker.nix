{pkgs, ...}: {
  nix.settings = {
    substituters = ["https://walker.cachix.org" "https://walker-git.cachix.org"];
    trusted-public-keys = ["walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM=" "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="];
  };

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
