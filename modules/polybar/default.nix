{ monitors, pkgs, config }:
let
  bars = import ./bars.nix { inherit monitors; };
  modules = import ./modules.nix;
in
{
  enable = true;
  package = pkgs.polybar.override {
    i3Support = true;
    alsaSupport = true;
    iwSupport = true;
    githubSupport = true;
  };
  script = (builtins.concatStringsSep " & "
    (builtins.concatMap
      (mon: [
        "polybar top-${mon} --config=${config.xdg.configHome}/polybar/config.ini"
        "polybar bottom-${mon} --config=${config.xdg.configHome}/polybar/config.ini"
      ])
      monitors
    )) + " &";
  settings = bars // modules;
}
