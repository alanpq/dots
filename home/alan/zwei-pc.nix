{
  inputs,
  outputs,
  pkgs,
  ...
}: let
  lib = pkgs.lib;
in {
  imports = [
    ./global
    # ./features/desktop/kde
    ./features/desktop/hyprland
    ./features/desktop/wireless

    ./features/desktop/common/vscode.nix

    ./features/games
    ./features/productivity

    ./features/libvirt
    # ./features/rgb
    # ./features/productivity
    # ./features/pass
    # ./features/games
    # ./features/games/star-citizen.nix
    # ./features/music
  ];

  colorscheme = inputs.nix-colors.colorschemes.apathy;
  wallpaper = outputs.wallpapers.firewatch-purple;

  services.hypridle = {
    enable = lib.mkForce false;
  };

  home.packages = with pkgs; [
    bruno
    dbeaver-bin
    iaito
    radare2
    obs-studio

    imhex
    zed-editor
    vlc
  ];

  monitors = [
    {
      name = "DVI-D-1";
      width = 1920;
      height = 1080;
      workspace = "1";
      refreshRate = 144;
      x = 0;
    }
    {
      name = "DP-5";
      width = 1920;
      height = 1080;
      x = 1920;
      y = 0;
      workspace = "2";
      refreshRate = 144;
      # transform = 1; # rotate 90 deg
      primary = true;
    }
  ];
}
