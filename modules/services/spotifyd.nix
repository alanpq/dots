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
    # TODO: expose audio backend/device as nixos config
    xdg.config.files."spotifyd/spotifyd.conf".source = (pkgs.formats.toml {}).generate "spotifyd.conf" {
      global = {
        backend = "pulseaudio";
        device = "music_output";
        initial_volume = 50;
      };
    };
  };
}
