{
  outputs,
  config,
  lib,
  pkgs,
  ...
}: let
  # Dependencies
  cat = "${pkgs.coreutils}/bin/cat";
  cut = "${pkgs.coreutils}/bin/cut";
  find = "${pkgs.findutils}/bin/find";
  grep = "${pkgs.gnugrep}/bin/grep";
  pgrep = "${pkgs.procps}/bin/pgrep";
  tail = "${pkgs.coreutils}/bin/tail";
  wc = "${pkgs.coreutils}/bin/wc";
  xargs = "${pkgs.findutils}/bin/xargs";
  timeout = "${pkgs.coreutils}/bin/timeout";
  ping = "${pkgs.iputils}/bin/ping";

  jq = "${pkgs.jq}/bin/jq";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  journalctl = "${pkgs.systemd}/bin/journalctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  playerctld = "${pkgs.playerctl}/bin/playerctld";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  wofi = "${pkgs.wofi}/bin/wofi";

  swaync-client = "${pkgs.swaynotificationcenter}/bin/swaync-client";

  # Function to simplify making waybar outputs
  jsonOutput = name: {
    pre ? "",
    text ? "",
    tooltip ? "",
    alt ? "",
    class ? "",
    percentage ? "",
  }: "${pkgs.writeShellScriptBin "waybar-${name}" ''
    set -euo pipefail
    ${pre}
    ${jq} -cn \
      --arg text "${text}" \
      --arg tooltip "${tooltip}" \
      --arg alt "${alt}" \
      --arg class "${class}" \
      --arg percentage "${percentage}" \
      '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
  ''}/bin/waybar-${name}";

  hasSway = config.wayland.windowManager.sway.enable;
  sway = config.wayland.windowManager.sway.package;
  hasHyprland = config.wayland.windowManager.hyprland.enable;
  hyprland = config.wayland.windowManager.hyprland.package;

  caway = "${pkgs.writeShellApplication {
    name = "caway";
    runtimeInputs = with pkgs; [playerctl jq cava];
    text = ''
      ${./scripts/caway.sh} "''$@"
    '';
  }}/bin/caway";
in {
  # Let it try to start a few more times
  systemd.user.services.waybar = {
    Unit.StartLimitBurst = 30;
  };
  programs.waybar = {
    enable = true;
    # package = pkgs.waybar.overrideAttrs (oa: {
    #   mesonFlags = (oa.mesonFlags or []) ++ ["-Dexperimental=true"];
    # });
    systemd.enable = true;
    settings = let
      inherit (config.colorscheme) colors;
    in {
      primary = {
        # mode = "dock";
        layer = "top";
        position = "top";

        height = 45;
        margin-top = 0;
        margin-left = 5;
        margin-right = 5;
        margin-bottom = 5;

        spacing = "0";

        modules-left =
          [
            # "custom/menu"
          ]
          ++ (lib.optionals hasSway [
            "sway/workspaces"
            "sway/mode"
          ])
          ++ (lib.optionals hasHyprland [
            "hyprland/workspaces"
            "hyprland/submap"
          ])
          ++ [
          ];

        modules-center = [
          # "custom/currentplayer"
          "custom/music"
        ];

        modules-right = [
          "network"
          "pulseaudio"
          "backlight"
          "battery"
          "custom/notifications"
          "tray"
          "clock"
          # "custom/weather",
          # "custom/cycle_wall",
          # "custom/clipboard",
          # "custom/power"
          # "custom/custom"
        ];

        "custom/music" = {
          format = "{icon}{text}";
          format-icons = {
            # Playing= " "; # Uncomment if not using the dynamic script
            Paused = " ";
            Stopped = "&#x202d;ﭥ "; #// This stop symbol is RTL. So &#x202d; is left-to-right override.
          };
          escape = true;
          tooltip = true;
          exec = "${caway} -b 10 ";
          return-type = "json";
          on-click = "playerctl play-pause";
          on-scroll-up = "playerctl previous";
          on-scroll-down = "playerctl next";
          on-click-right = "amberol";
          max-length = 35;
        };

        "custom/notifications" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
          };
          return-type = "json";
          exec = "${swaync-client} -swb";
          on-click = "sleep 0.15 && ${swaync-client} -t -sw";
          on-click-right = "sleep 0.15 && ${swaync-client} -d -sw";
          escape = true;
        };

        clock = {
          interval = 1;
          format = "{0:%d/%m %H:%M:}<span alpha='60%'>{0:%S}</span>";
          # format = "{:%d-%m}";
          format-alt = "{:%Y-%m-%d %H:%M:%S %z}";
          on-click-left = "mode";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar-weeks-pos = "right";
          today-format = "<span color='#f38ba8'><b><u>{}</u></b></span>";
          format-calendar = "<span color='#f2cdcd'><b>{}</b></span>";
          format-calendar-weeks = "<span color='#94e2d5'><b>W{:%U}</b></span>";
          format-calendar-weekdays = "<span color='#f9e2af'><b>{}</b></span>";
        };
        "custom/power" = {
          format = "{}";
          # // "exec": "~/.scripts/tools/expand power",
          exec = "echo '{\"text\":\"⏻\":\"tooltip\":\"Power\"}'";
          return-type = "json";
          # on-click = "~/.config/wlogout/launch.sh";
        };
        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "   0%";
          format-icons = {
            headphone = "󰋋";
            headset = "󰋎";
            portable = "";
            default = ["" "" ""];
          };
          on-click = pavucontrol;
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰒳";
            deactivated = "󰒲";
          };
        };
        battery = {
          bat = "BAT0";
          interval = 10;
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          onclick = "";
        };
        "sway/window" = {
          max-length = 20;
        };
        network = {
          interval = 3;
          format-wifi = "   {essid}";
          format-ethernet = "󰈁 Connected";
          format-disconnected = "";
          tooltip-format = ''
            {ifname}
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          on-click = "";
        };
        "custom/tailscale-ping" = {
          interval = 10;
          return-type = "json";
          exec = let
            inherit (builtins) concatStringsSep attrNames;
            hosts = attrNames outputs.nixosConfigurations;
            homeMachine = "merope";
            remoteMachine = "alcyone";
          in
            jsonOutput "tailscale-ping" {
              # Build variables for each host
              pre = ''
                set -o pipefail
                ${concatStringsSep "\n" (map (host: ''
                    ping_${host}="$(${timeout} 2 ${ping} -c 1 -q ${host} 2>/dev/null | ${tail} -1 | ${cut} -d '/' -f5 | ${cut} -d '.' -f1)ms" || ping_${host}="Disconnected"
                  '')
                  hosts)}
              '';
              # Access a remote machine's and a home machine's ping
              text = "  $ping_${remoteMachine} /  $ping_${homeMachine}";
              # Show pings from all machines
              tooltip = concatStringsSep "\n" (map (host: "${host}: $ping_${host}") hosts);
            };
          format = "{}";
          on-click = "";
        };
        "custom/menu" = {
          return-type = "json";
          exec = jsonOutput "menu" {
            text = "";
            tooltip = ''$(${cat} /etc/os-release | ${grep} PRETTY_NAME | ${cut} -d '"' -f2)'';
          };
          on-click-left = "${wofi} -S drun -x 10 -y 10 -W 25% -H 60%";
          on-click-right = lib.concatStringsSep ";" (
            (lib.optional hasHyprland "${hyprland}/bin/hyprctl dispatch togglespecialworkspace")
            ++ (lib.optional hasSway "${sway}/bin/swaymsg scratchpad show")
          );
        };
        "custom/hostname" = {
          exec = "echo $USER@$HOSTNAME";
          on-click = "${systemctl} --user restart waybar";
        };
        "custom/unread-mail" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "unread-mail" {
            pre = ''
              count=$(${find} ~/Mail/*/Inbox/new -type f | ${wc} -l)
              if ${pgrep} mbsync &>/dev/null; then
                status="syncing"
              else if [ "$count" == "0" ]; then
                status="read"
              else
                status="unread"
              fi
              fi
            '';
            text = "$count";
            alt = "$status";
          };
          format = "{icon}  ({})";
          format-icons = {
            "read" = "󰇯";
            "unread" = "󰇮";
            "syncing" = "󰁪";
          };
        };
        # "custom/gpg-agent" = {
        #   interval = 2;
        #   return-type = "json";
        #   exec =
        #     let gpgCmds = import ../../../cli/gpg-commands.nix { inherit pkgs; };
        #     in
        #     jsonOutput "gpg-agent" {
        #       pre = ''status=$(${gpgCmds.isUnlocked} && echo "unlocked" || echo "locked")'';
        #       alt = "$status";
        #       tooltip = "GPG is $status";
        #     };
        #   format = "{icon}";
        #   format-icons = {
        #     "locked" = "";
        #     "unlocked" = "";
        #   };
        #   on-click = "";
        # };
        "custom/gammastep" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "gammastep" {
            pre = ''
              if unit_status="$(${systemctl} --user is-active gammastep)"; then
                status="$unit_status ($(${journalctl} --user -u gammastep.service -g 'Period: ' | ${tail} -1 | ${cut} -d ':' -f6 | ${xargs}))"
              else
                status="$unit_status"
              fi
            '';
            alt = "\${status:-inactive}";
            tooltip = "Gammastep is $status";
          };
          format = "{icon}";
          format-icons = {
            "activating" = "󰁪 ";
            "deactivating" = "󰁪 ";
            "inactive" = "? ";
            "active (Night)" = " ";
            "active (Nighttime)" = " ";
            "active (Transition (Night)" = " ";
            "active (Transition (Nighttime)" = " ";
            "active (Day)" = " ";
            "active (Daytime)" = " ";
            "active (Transition (Day)" = " ";
            "active (Transition (Daytime)" = " ";
          };
          on-click = "${systemctl} --user is-active gammastep && ${systemctl} --user stop gammastep || ${systemctl} --user start gammastep";
        };
        "custom/currentplayer" = {
          interval = 2;
          return-type = "json";
          exec = jsonOutput "currentplayer" {
            pre = ''
              player="$(${playerctl} status -f "{{playerName}}" 2>/dev/null || echo "No player active" | ${cut} -d '.' -f1)"
              count="$(${playerctl} -l 2>/dev/null | ${wc} -l)"
              if ((count > 1)); then
                more=" +$((count - 1))"
              else
                more=""
              fi
            '';
            alt = "$player";
            tooltip = "$player ($count available)";
            text = "$more";
          };
          format = "{icon}{}";
          format-icons = {
            "No player active" = " ";
            "Celluloid" = "󰎁 ";
            "spotify" = "󰓇 ";
            "ncspot" = "󰓇 ";
            "qutebrowser" = "󰖟 ";
            "firefox" = " ";
            "discord" = " 󰙯 ";
            "sublimemusic" = " ";
            "kdeconnect" = "󰄡 ";
            "chromium" = " ";
          };
          on-click = "${playerctld} shift";
          on-click-right = "${playerctld} unshift";
        };
        "custom/player" = {
          exec-if = "${playerctl} status 2>/dev/null";
          exec = ''${playerctl} metadata --format '{"text": "{{title}} - {{artist}}", "alt": "{{status}}", "tooltip": "{{title}} - {{artist}} ({{album}})"}' 2>/dev/null '';
          return-type = "json";
          interval = 2;
          max-length = 30;
          format = "{icon} {}";
          format-icons = {
            "Playing" = "󰐊";
            "Paused" = "󰏤 ";
            "Stopped" = "󰓛";
          };
          on-click = "${playerctl} play-pause";
        };
      };
    };
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style = let
      inherit (config.colorscheme) colors;
    in
      /*
      css
      */
      ''
              @define-color base #1e1e2e;
            @define-color mantle #181825;
            @define-color crust #11111b;

            @define-color text #cdd6f4;
            @define-color subtext0 #a6adc8;
            @define-color subtext1 #bac2de;

            @define-color surface0 rgba(22, 25, 37, 0.9);
            @define-color surface1 #45475a;
            @define-color surface2 #585b70;
            @define-color surface3 #394161;

            @define-color overlay0 #6c7086;
            @define-color overlay1 #7f849c;
            @define-color overlay2 #9ba3c3;

            @define-color blue #89b4fa;
            @define-color lavender #b4befe;
            @define-color sapphire #74c7ec;
            @define-color sky #89dceb;
            @define-color teal #94e2d5;
            @define-color green #a6e3a1;
            @define-color yellow #f9e2af;
            @define-color peach #fab387;
            @define-color maroon #eba0ac;
            @define-color red #f38ba8;
            @define-color mauve #cba6f7;
            @define-color pink #f5c2e7;
            @define-color flamingo #f2cdcd;
            @define-color rosewater #f5e0dc;

        /* =============================== */
        /* Universal Styling */
        * {
          border: none;
          border-radius: 0;
          font-family: 'CaskaydiaCove Nerd Font', monospace;
          font-size: 13px;
          min-height: 0;
        }

        /* =============================== */


        /* =============================== */
        /* Bar Styling */
        #waybar {
          background: transparent;
          color: @text;
        }

        /* =============================== */


        /* =============================== */
        /* Main Modules */
        #custom-launcher,
        #workspaces,
        #window,
        #tray,
        #backlight,
        #clock,
        #battery,
        #pulseaudio,
        #network,
        #mpd,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #custom-music,
        #custom-updates,
        #custom-nordvpn,
        #custom-notifications,
        #custom-power,
        #custom-custom,
        #custom-cycle_wall,
        #custom-clipboard,
        #custom-ss,
        #custom-weather {
          background-color: @surface0;
          color: @text;
          border-radius: 16px;
          padding: 0.5rem 1rem;
          box-shadow: rgba(0, 0, 0, 0.116) 2px 2px 5px 2px;
          margin-top: 5px;
          /*
            margin-bottom: 10px;
        */
          margin-right: 10px;
        }

        /* =============================== */
        /* Launcher Module */
        #custom-launcher {
          color: @green;
          padding-top: 0px;
          padding-bottom: 0px;
          padding-right: 10px;
        }

        /* =============================== */
        /* Workspaces */
        #workspaces {
          padding-left: 8px;
          padding-right: 8px;
        }

        #workspaces * {
          font-size: 0px;
        }

        #workspaces button {
          background-color: @surface3;
          color: @mauve;
          border-radius: 100%;
          min-height: 14px;
          min-width: 14px;
          margin: 5px 8px;
          padding: 0px;
          /*transition: all 0.5s cubic-bezier(0.33, 1.0, 0.68, 1.0); easeInOutCubic */
          transition: all 0.5s cubic-bezier(.55, -0.68, .48, 1.68);
          box-shadow: rgba(0, 0, 0, 0.288) 2px 2px 5px 2px;
        }

        #workspaces button.active {
          /*color: @surface0;
            border-radius: 1rem;
            padding: 0rem 10px;*/
          background: radial-gradient(circle, rgba(203, 166, 247, 1) 0%, rgba(193, 168, 247, 1) 12%, rgba(249, 226, 175, 1) 19%, rgba(189, 169, 247, 1) 20%, rgba(182, 171, 247, 1) 24%, rgba(198, 255, 194, 1) 36%, rgba(177, 172, 247, 1) 37%, rgba(170, 173, 248, 1) 48%, rgba(255, 255, 255, 1) 52%, rgba(166, 174, 248, 1) 52%, rgba(160, 175, 248, 1) 59%, rgba(148, 226, 213, 1) 66%, rgba(155, 176, 248, 1) 67%, rgba(152, 177, 248, 1) 68%, rgba(205, 214, 244, 1) 77%, rgba(148, 178, 249, 1) 78%, rgba(144, 179, 250, 1) 82%, rgba(180, 190, 254, 1) 83%, rgba(141, 179, 250, 1) 90%, rgba(137, 180, 250, 1) 100%);
          background-size: 400% 400%;
          animation: gradient_f 20s ease-in-out infinite;
          transition: all 0.3s cubic-bezier(.55, -0.68, .48, 1.682);
        }

        #workspaces button:hover {
          background-color: @mauve;
        }

        @keyframes gradient {
          0% {
            background-position: 0% 50%;
          }

          50% {
            background-position: 100% 30%;
          }

          100% {
            background-position: 0% 50%;
          }
        }

        @keyframes gradient_f {
          0% {
            background-position: 0% 200%;
          }

          50% {
            background-position: 200% 0%;
          }

          100% {
            background-position: 400% 200%;
          }
        }

        @keyframes gradient_f_nh {
          0% {
            background-position: 0% 200%;
          }

          100% {
            background-position: 200% 200%;
          }
        }

        /* =============================== */


        /* =============================== */
        /* System Monitoring Modules */
        #cpu,
        #memory,
        #temperature {
          color: @blue;
        }

        #cpu {
          border-top-right-radius: 0;
          border-bottom-right-radius: 0;
          margin-right: 0px;
          padding-right: 5px;
        }

        #memory {
          border-radius: 0px;
          margin-right: 0px;
          padding-left: 5px;
          padding-right: 5px;
        }

        #temperature {
          border-radius: 0px;
          margin-right: 0px;
          padding-left: 5px;
          padding-right: 5px;
        }

        #disk {
          color: @peach;
          border-top-left-radius: 0;
          border-bottom-left-radius: 0;
          padding-left: 5px;
          padding-right: 1rem;
        }

        /* Updates Module */
        #custom-updates {
          color: @sky;
        }

        /* =============================== */


        /* =============================== */
        /* Clock Module */
        #clock {
          color: @flamingo;
          margin-right: 0;
        }

        /* =============================== */


        #custom-music.low {
          background: rgb(148, 226, 213);
          background: linear-gradient(52deg, rgba(148, 226, 213, 1) 0%, rgba(137, 220, 235, 1) 19%, rgba(116, 199, 236, 1) 43%, rgba(137, 180, 250, 1) 56%, rgba(180, 190, 254, 1) 80%, rgba(186, 187, 241, 1) 100%);
          background-size: 300% 300%;
          text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
          /*animation: gradient 15s ease infinite;*/
          font-weight: bold;
          color: #fff;
        }

        #custom-music.random {
          background: rgb(148, 226, 213);
          background: radial-gradient(circle, rgba(148, 226, 213, 1) 0%, rgba(156, 227, 191, 1) 21%, rgba(249, 226, 175, 1) 34%, rgba(158, 227, 186, 1) 35%, rgba(163, 227, 169, 1) 59%, rgba(148, 226, 213, 1) 74%, rgba(164, 227, 167, 1) 74%, rgba(166, 227, 161, 1) 100%);
          background-size: 400% 400%;
          /*animation: gradient_f 4s ease infinite;*/
          text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
          font-weight: bold;
          color: #fff;
        }

        #custom-music.critical {
          background: rgb(235, 160, 172);
          background: linear-gradient(52deg, rgba(235, 160, 172, 1) 0%, rgba(243, 139, 168, 1) 30%, rgba(231, 130, 132, 1) 48%, rgba(250, 179, 135, 1) 77%, rgba(249, 226, 175, 1) 100%);
          background-size: 300% 300%;
          /*animation: gradient 15s cubic-bezier(.55, -0.68, .48, 1.68) infinite;*/
          text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
          font-weight: bold;
          color: #fff;
        }

        #custom-music.Playing {
          background: rgb(137, 180, 250);
          background: radial-gradient(circle, rgba(137, 180, 250, 120) 0%, rgba(142, 179, 250, 120) 6%, rgba(148, 226, 213, 1) 14%, rgba(147, 178, 250, 1) 14%, rgba(155, 176, 249, 1) 18%, rgba(245, 194, 231, 1) 28%, rgba(158, 175, 249, 1) 28%, rgba(181, 170, 248, 1) 58%, rgba(205, 214, 244, 1) 69%, rgba(186, 169, 248, 1) 69%, rgba(195, 167, 247, 1) 72%, rgba(137, 220, 235, 1) 73%, rgba(198, 167, 247, 1) 78%, rgba(203, 166, 247, 1) 100%);
          background-size: 400% 400%;
          /*animation: gradient_f 9s cubic-bezier(.72, .39, .21, 1) infinite;*/
          text-shadow: 0px 0px 5px rgba(0, 0, 0, 0.377);
          font-weight: bold;
          color: #fff;
        }

        #custom-music.Paused,
        #custom-music.Stopped {
          background: @surface0;
        }


        /* =============================== */
        /* Music/PlayerCTL Module */
        #custom-music {
          color: @mauve;
          /*animation: none;*/
        }

        /* =============================== */


        /* =============================== */
        /* Network Module */
        #network {
          color: @blue;
          border-top-right-radius: 0;
          border-bottom-right-radius: 0;
          margin-right: 0px;
          padding-right: 5px;
        }

        /* =============================== */


        /* =============================== */
        /* PulseAudio Module */
        #pulseaudio {
          color: @mauve;
          border-radius: 0;
          margin-right: 0px;
          padding-left: 5px;
          padding-right: 5px;
        }

        /* =============================== */


        /* =============================== */
        /* Backlight Module */
        #backlight {
          color: @teal;
          border-radius: 0;
          margin-right: 0px;
          padding-left: 5px;
          padding-right: 5px;
        }

        /* =============================== */


        /* =============================== */
        /* Battery Module */
        #battery {
          color: @green;
          border-radius: 0;
          margin-right: 0px;
          padding-left: 5px;
          padding-right: 5px;
        }

        #battery.charging {
          color: @green;
        }

        #battery.warning:not(.charging) {
          color: @maroon;
        }

        #battery.critical:not(.charging) {
          color: @red;
          animation-name: blink;
          animation-duration: 1s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        @keyframes blink {
          to {
            background: @red;
            color: @surface1;
          }
        }

        /* =============================== */

        /* Notifications Module */
        #custom-notifications {
          color: @mauve;
          border-top-left-radius: 0;
          border-bottom-left-radius: 0;
          padding-left: 5px;
          padding-right: 1.25rem;
        }


        /* =============================== */
        /* Tray Module */
        #tray {
          color: @mauve;
          padding-right: 1.25rem;
        }

        /* =============================== */


        /* =============================== */
        /* |       Custom Modules        | */
        /* =============================== */
        #custom-custom {
          color: @peach;
          padding-right: 1.25rem;
          margin-right: 0px;
        }

        /* Screenshot */
        #custom-ss {
          color: @mauve;
          padding-right: 1.5rem;
        }

        /* Wallpaper */
        #custom-cycle_wall {
          background: linear-gradient(45deg, rgba(245, 194, 231, 1) 0%, rgba(203, 166, 247, 1) 0%, rgba(243, 139, 168, 1) 13%, rgba(235, 160, 172, 1) 26%, rgba(250, 179, 135, 1) 34%, rgba(249, 226, 175, 1) 49%, rgba(166, 227, 161, 1) 65%, rgba(148, 226, 213, 1) 77%, rgba(137, 220, 235, 1) 82%, rgba(116, 199, 236, 1) 88%, rgba(137, 180, 250, 1) 95%);
          background-size: 500% 500%;
          animation: gradient 7s linear infinite;
        }

        /* Notifications Module */
        #custom-clipboard {
          color: @mauve;
          border-top-right-radius: 0;
          border-bottom-right-radius: 0;
          margin-right: 0px;
          padding-right: 8px;
        }

        /* Powermenu Module */
        #custom-power {
          color: @mauve;
          /* border-top-left-radius: 0;
          border-bottom-left-radius: 0;
          padding-left: 8px; */
          padding-right: 1.20rem;
        }

        /* =============================== */
      '';
  };
}
