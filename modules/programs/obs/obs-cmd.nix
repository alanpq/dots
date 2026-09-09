{
  flake.modules.hjem.obs = {
    pkgs,
    config,
    ...
  }: let
    cfg = config.programs.obs-studio;
  in {
    packages = [
      (pkgs.writeShellApplication {
        name = "obs-cmd";
        runtimeInputs = [pkgs.obs-cmd];
        text = ''
          export OBS_WEBSOCKET_URL="obsws://127.0.0.1:${toString cfg.websocket.port}/${cfg.websocket.password}"
          exec obs-cmd "$@"
        '';
      })

      (pkgs.writeShellScriptBin "obs-save-replay" ''
        output=$(timeout 0.1s obs-cmd replay save 2>&1 >/dev/null)
        status="$?"
        message="$output"
        args=()
        case "$status" in
            0)
                ${pkgs.pipewire}/bin/pw-play --volume 0.5 ${./click.wav}
                exit 0
            ;;
            124)
                message="OBS (ws) is not running!"
                args+=(-A "Start OBS")
            ;;
            *)
                if [[ "$output" == *"OutputNotRunning"* ]]; then
                    message="Replay buffer was not started (starting now)"
                    obs-cmd replay start &
                else
                    message="$output"
                fi
            ;;
        esac
        action=$(${pkgs.libnotify}/bin/notify-send "Failed to save replay" "$message" -a Clips -u critical "''${args[@]}")
        case "$action" in
            0) obs --startreplaybuffer --minimize-to-tray >/dev/null 2>&1 </dev/null & disown;;
            *) ;;
        esac
      '')
    ];

    xdg.config.files."obsws-cli/obsws.env".text = ''
      OBSWS_CLI_HOST=localhost
      OBSWS_CLI_PORT=${toString cfg.websocket.port}
      OBSWS_CLI_PASSWORD=${cfg.websocket.password}
    '';
  };
}
