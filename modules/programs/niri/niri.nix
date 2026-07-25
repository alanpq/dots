{
  pkgs,
  lib,
  ...
}: {
  flake.modules.nixos.niri = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      wl-clipboard
      wtype
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xwayland-satellite

      grim
      slurp
      swappy
      wf-recorder
      brightnessctl

      adw-gtk3
      gnome-themes-extra
      papirus-icon-theme
    ];

    programs.niri.enable = true;
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;

    xdg.portal.config = {
      common = {
        default = [
          "gtk"
          "gnome"
        ];
      };
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
  flake.modules.hjem.niri = let
    mkSimple = value: {action = value;};
  in {
    rum.desktops.niri = {
      enable = true;
      config =
        builtins.readFile ./config.kdl
        + ''
          debug {
              // wait-for-frame-completion-before-queueing
              render-drm-device "/dev/dri/renderD129"
          }
        '';

      binds =
        {
          "Mod+O" = {
            action = "toggle-overview";
            parameters = {repeat = false;};
          };
          "Mod+Q" = {
            action = "close-window";
            parameters = {repeat = false;};
          };

          "Mod+Slash" = {
            action = "show-hotkey-overlay";
            parameters = {
              hotkey-overlay-title = "Cheatsheet";
            };
          };

          "Mod+Return" = {
            spawn = ["alacritty"];
            parameters = {
              hotkey-overlay-title = "Open Terminal";
            };
          };
          "Mod+Shift+Return" = {
            spawn = ["firefox"];
            parameters = {
              hotkey-overlay-title = "Open Browser";
            };
          };

          "Mod+Space" = {
            spawn = ["walker"];
            parameters = {
              hotkey-overlay-title = "App Launcher";
            };
          };
        }
        // builtins.mapAttrs (_name: mkSimple) {
          "Print" = "screenshot";
          "Ctrl+Print" = "screenshot-screen";
          "Alt+Print" = "screenshot-window";
        }
        // builtins.mapAttrs (_name: mkSimple) (
          lib.attrsets.mergeAttrsList (
            map (v:
              {
                "${v.key}+Left" = "${v.verb}-column-left";
                "${v.key}+Down" = "${v.verb}-window-down";
                "${v.key}+Up" = "${v.verb}-window-up";
                "${v.key}+Right" = "${v.verb}-column-right";
                "${v.key}+H" = "${v.verb}-column-left";
                "${v.key}+L" = "${v.verb}-column-right";
              }
              // (let
                mkAction =
                  if v.verb == "focus"
                  then dir: "focus-window-or-workspace-${dir}"
                  else dir: "move-window-${dir}-or-to-workspace-${dir}";
              in {
                "${v.key}+J" = mkAction "down";
                "${v.key}+K" = mkAction "up";
              })) [
              {
                verb = "focus";
                key = "Mod";
              }
              {
                verb = "move";
                key = "Mod+Ctrl";
              }
            ]
          )
        )
        // builtins.mapAttrs (_name: value: {
          parameters = {allow-when-locked = true;};
          spawn = value;
        }) {
          "XF86AudioRaiseVolume" = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];

          "XF86AudioLowerVolume" = ["wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"];
          "XF86AudioMute" = ["wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"];
          "XF86AudioMicMute" = ["wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"];

          "XF86AudioPlay" = ["noctalia-shell ipc call media playPause"];
          "XF86AudioNext" = ["noctalia-shell ipc call media next"];
          "XF86AudioPrev" = ["noctalia-shell ipc call media previous"];

          "XF86MonBrightnessUp" = ["brightnessctl" "--class=backlight" "set" "+10%"];
          "XF86MonBrightnessDown" = ["brightnessctl" "--class=backlight" "set" "10%-"];
        };
    };
  };
}
