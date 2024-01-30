{ inputs, outputs, ... }: {
  imports = [
    ./global
    ./features/desktop/hyprland
    ./features/desktop/wireless

    ./features/desktop/common/vscode.nix

    ./features/libvirt
    # ./features/rgb
    # ./features/productivity
    # ./features/pass
    # ./features/games
    # ./features/games/star-citizen.nix
    # ./features/music
  ];

  colorscheme = inputs.nix-colors.colorschemes.paraiso;
  wallpaper = outputs.wallpapers.firewatch-purple;

  monitors = [
    {
      name = "DP-3";
      width = 1920;
      height = 1080;
      workspace = "1";
      x = 1080;
      y = 600;
      refreshRate = 144;
      primary = true;
    }
    {
      name = "DVI-D-1";
      width = 1920;
      height = 1080;
      workspace = "2";
      refreshRate = 144;
      transform = 1; # rotate 90 deg
      x = 0;
    }
  ];
}
