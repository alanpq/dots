{ inputs, outputs, ... }: {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/desktop/wireless
    ./features/desktop/common/vscode.nix
    # ./features/rgb
    ./features/productivity
    # ./features/pass
    # ./features/games
    # ./features/games/star-citizen.nix
    # ./features/music
  ];

  colorscheme = inputs.nix-colors.colorschemes.atlas;
  wallpaper = outputs.wallpapers.firewatch-purple;

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      workspace = "1";
      x = 0;
      primary = true;
    }
    {
      name = "HDMI-1";
      width = 1920;
      height = 1080;
      workspace = "2";
      x = 0;
    }
  ];
}
