{lib, ...}: {
  home = {
    sessionVariables = {
      TERMINAL = lib.mkForce "alacritty";
    };
  };
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        decorations = "None";
        dynamic_padding = true;
        blur = true;
        opacity = 0.6;
      };
    };
  };
}
