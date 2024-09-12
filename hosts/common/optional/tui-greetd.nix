{ pkgs, lib, config, ... }:
let
  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (n: v: "${v.home.path}/share") homeCfgs;
  vars = ''XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}"'';

  alanCfg = homeCfgs.alan;
  gtkTheme = alanCfg.gtk.theme;
  iconTheme = alanCfg.gtk.iconTheme;

  session = "${alanCfg.wayland.windowManager.hyprland.package}/bin/Hyprland";
  # wallpaper = alanCfg.wallpaper;
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

  services.greetd = {
    enable = true;
    # vt = 2;
    settings = {
      default_session = {
        command = ''${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-user-session --cmd ${session}'';
        user = "greeter";
      };
      initial_session = {
        command = ''${session}'';
        user = "alan";
      };
    };
  };
}
