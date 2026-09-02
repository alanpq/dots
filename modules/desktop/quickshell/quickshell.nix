{inputs, ...}: {
  flake.modules.hjem.quickshell = {pkgs, ...}: let
    quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    packages = [quickshell];

    # quickshell loads $XDG_CONFIG_HOME/quickshell/shell.qml by default.
    xdg.config.files."quickshell/shell.qml".source = ./shell.qml;

    systemd.services.quickshell = {
      description = "Quickshell desktop shell";
      documentation = ["https://quickshell.org"];
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      bindsTo = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${quickshell}/bin/quickshell";
        Restart = "on-failure";
        RestartSec = "2";
        Slice = "session.slice";
      };
    };
  };
}
