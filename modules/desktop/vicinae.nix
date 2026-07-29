{inputs, ...}: {
  flake-file.inputs.vicinae = {
    url = "github:vicinaehq/vicinae";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.hjem.vicinae = {pkgs, ...}: let
    vicinae = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    packages = [vicinae];
    systemd.services.vicinae = {
      description = "Vicinae server daemon";
      documentation = ["https://docs.vicinae.com"];
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      bindsTo = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${vicinae}/bin/vicinae server";
        Restart = "always";
        RestartSec = "5";
        KillMode = "process";
        Environment = [
          "USE_LAYER_SHELL=1"
          "PATH=/run/current-system/sw/bin:${pkgs.coreutils}/bin:${pkgs.findutils}/bin"
        ];
      };
    };
    desktop.appLauncher = {
      package = vicinae;
      openCmd = "${vicinae}/bin/vicinae open";
    };
  };
}
