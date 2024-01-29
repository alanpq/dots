{ pkgs, lib, config, ... }:
let
  homeCfgs = config.home-manager.users;
  homeSharePaths = lib.mapAttrsToList (n: v: "${v.home.path}/share") homeCfgs;
  vars = ''XDG_DATA_DIRS="$XDG_DATA_DIRS:${lib.concatStringsSep ":" homeSharePaths}"'';

  alanCfg = homeCfgs.alan;
  gtkTheme = alanCfg.gtk.theme;
  iconTheme = alanCfg.gtk.iconTheme;
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
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --sessions '${lib.concatStringsSep ":" homeSharePaths}'";
      user = "greeter";
    };
  };
}
