{ inputs, outputs, pkgs, ... }: let
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
    "${fetchTarball {
      url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
      sha256 = "1rq8mrlmbzpcbv9ys0x88alw30ks70jlmvnfr2j8v830yy5wvw7h";
    }}/modules/vscode-server/home.nix"
  ];

  services.vscode-server.enable = true;

  colorscheme = inputs.nix-colors.colorschemes.heetch;
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
    jetbrains.webstorm
    jetbrains.rust-rover
    jetbrains-toolbox

    imhex
  ];

  monitors = [
    {
      name = "DP-6";
      width = 1920;
      height = 1080;
      workspace = "1";
      x = 1920;
      y = 0;
      refreshRate = 144;
    }
    {
      name = "DVI-D-1";
      width = 1920;
      height = 1080;
      workspace = "2";
      refreshRate = 144;
      # transform = 1; # rotate 90 deg
      x = 0;
      primary = true;
    }
  ];
}
