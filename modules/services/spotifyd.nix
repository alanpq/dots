{
  flake.modules.hjem.spotifyd = {pkgs, ...}: {
    systemd.services.spotifyd = {
      description = "spotifyd";
      after = ["pipewire.service"];
      requires = ["pipewire.service"];

      serviceConfig = {
        ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon";
        Restart = "on-failure";
      };

      wantedBy = ["default.target"];
    };
  };
}
