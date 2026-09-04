{
  flake.modules.hjem.alacritty = {
    pkgs,
    osConfig,
    ...
  }: {
    rum.programs.alacritty = {
      enable = true;
      package = pkgs.alacritty;

      settings = {
        colors = with osConfig.theme.colors; {
          primary = {
            foreground = base05;
            background = base00;
            bright_foreground = base07;
          };
          selection = {
            text = base05;
            background = base02;
          };
          cursor = {
            text = base00;
            cursor = base05;
          };
          normal = {
            black = base00;
            white = base05;
            red = base08;
            green = base0B;
            yellow = base0A;
            blue = base0D;
            magenta = base0E;
            cyan = base0C;
          };
          bright = {
            black = base03;
            white = base07;
            red = base08;
            green = base0B;
            yellow = base0A;
            blue = base0D;
            magenta = base0E;
            cyan = base0C;
          };
        };

        font = {
          normal = {
            family = osConfig.theme.fonts.monospace.name;
            style = "Regular";
          };
          size = osConfig.theme.fonts.sizes.terminal;
        };

        window = {
          blur = true;
          decorations = "None";
          dynamic_padding = true;
          opacity = 0.6;
        };
      };
    };
  };
}
