{
  flake.modules.hjem.alacritty = {lib, pkgs, ...}: {
    rum.programs.alacritty = {
      enable = true;
      package = pkgs.alacritty;

      settings = {
        font.size = lib.mkDefault 10;
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
