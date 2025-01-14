{
  inputs,
  outputs,
  config,
  lib,
  ...
}: {
  imports = [
    ./global
    ./features/desktop/wireless
  ];

  colorscheme = inputs.nix-colors.colorschemes.heetch;
  wallpaper = outputs.wallpapers.firewatch-purple;

  home = {
    username = lib.mkForce "nixos";
    # homeDirectory = lib.mkDefault "/home/${config.home.username}";
  };
  home.stateVersion = lib.trivial.release;

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
