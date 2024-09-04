{ pkgs, lib, config, ... }:
let
  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (n: v: "${v.home.path}/share") homeCfgs;
  vars = ''XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}"'';

  alanCfg = homeCfgs.alan;
  gtkTheme = alanCfg.gtk.theme;
  iconTheme = alanCfg.gtk.iconTheme;
  # wallpaper = alanCfg.wallpaper;


  # val=$(udevadm info -a -n /dev/dri/card1 | grep boot_vga | rev | cut -c 2)
  # WLR_DRM_DEVICES=\"/dev/dri/card$val\" 

  sway-kiosk = command: "
    ${lib.getExe pkgs.sway} --unsupported-gpu --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    xwayland disable
    input "type:touchpad" {
      tap enabled
    }
    exec 'GTK_USE_PORTAL=0 ${vars} ${command}; ${pkgs.sway}/bin/swaymsg exit'
  ''}
  ";
in
{
  users.extraUsers.greeter = {
    packages = [
      gtkTheme.package
      iconTheme.package
    ];
    # For caching and such
    home = "/tmp/greeter-home";
    createHome = true;
  };

  programs.regreet = {
    enable = true;
    settings = {
      GTK = {
        icon_theme_name = lib.mkDefault "Papirus";
        theme_name = lib.mkDefault gtkTheme.name;
      };
      background = {
        # path = wallpaper;
        fit = "Cover";
      };
    };
  };
  services.greetd = {
    enable = true;
    settings.default_session.command = sway-kiosk (lib.getExe config.programs.regreet.package);
  };
}
