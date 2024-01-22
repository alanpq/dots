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
      name = "DP-2";
      width = 1920;
      height = 1080;
      workspace = "1";
      x = 1080;
      y = 600;
      primary = true;
    }
    {
      name = "DVI-D-0";
      width = 1080;
      height = 1920;
      workspace = "2";
      x = 0;
    }
  ];
}
