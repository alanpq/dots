{
  flake.modules.hjem.obs = {
    pkgs,
    lib,
    config,
    ...
  }: {
    options = let
      inherit (lib) mkOption types;
    in {
      programs.obs-studio = {
        websocket = {
          enable = mkOption {
            type = types.bool;
            default = true;
          };
          port = mkOption {
            type = types.port;
            default = 4455;
          };
          password = mkOption {
            type = types.str;
            default = "TPCI9HqunKOP4l05";
          };
        };
      };
    };
    config = let
      cfg = config.programs.obs-studio;
    in {
      packages = [
        pkgs.obs-studio
      ];

      xdg.data.files."applications/custom-obs-replay-buffer.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Name=OBS Replay Buffer
        GenericName=Streaming/Recording Software
        Comment=Free and Open Source Streaming/Recording Software
        Exec=obs --startreplaybuffer --minimize-to-tray
        Icon=com.obsproject.Studio
        Terminal=false
        Type=Application
        Categories=AudioVideo;Recorder;
        StartupNotify=true
        StartupWMClass=obs
      '';

      xdg.config.files."obs-studio/plugin_config/obs-websocket/config.json".text = builtins.toJSON {
        alerts_enabled = false;
        auth_required = true;
        first_load = false;
        server_enabled = cfg.websocket.enable;
        server_password = cfg.websocket.password;
        server_port = cfg.websocket.port;
      };

      rum.desktops.niri.binds = {
        "Mod+End" = {
          spawn = ["obs-save-replay"];
        };
      };
    };
  };
}
