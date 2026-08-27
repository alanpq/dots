{
  flake.modules.hjem.niri = {
    lib,
    config,
    ...
  }: let
    mkSimple = value: {action = value;};
  in {
    rum.desktops.niri = {
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
            spawn = lib.strings.splitString " " config.desktop.appLauncher.openCmd;
            parameters = {
              hotkey-overlay-title = "App Launcher";
            };
          };
        }
        // builtins.mapAttrs (_name: mkSimple) {
          "Mod+Tab" = "focus-workspace-previous";

          "Print" = "screenshot";
          "Ctrl+Print" = "screenshot-screen";
          "Alt+Print" = "screenshot-window";
          "Mod+Insert" = "screenshot";

          # Consume one window from the right to the bottom of the focused column.
          "Mod+Comma" = "consume-window-into-column";
          # Expel the bottom window from the focused column to the right.
          "Mod+Period" = "expel-window-from-column";

          "Mod+R" = "switch-preset-column-width";
          # Cycling through the presets in reverse order is also possible.
          # "Mod+R" = "switch-preset-column-width-back";
          "Mod+Shift+R" = "switch-preset-window-height";
          "Mod+Ctrl+R" = "reset-window-height";
          "Mod+F" = "maximize-column";
          "Mod+Shift+F" = "fullscreen-window";

          # Expand the focused column to space not taken up by other fully visible columns.
          "Mod+Ctrl+F" = "expand-column-to-available-width";

          "Mod+C" = "center-column";

          # Center all fully visible columns on screen.
          "Mod+Ctrl+C" = "center-visible-columns";

          "Mod+Minus" = ''set-column-width "-10%"'';
          "Mod+Equal" = ''set-column-width "+10%"'';

          # Finer height adjustments when in column with other windows.
          "Mod+Shift+Minus" = ''set-window-height "-10%"'';
          "Mod+Shift+Equal" = ''set-window-height "+10%"'';

          # Move the focused window between the floating and the tiling layout.
          "Mod+V" = "toggle-window-floating";
          "Mod+Shift+V" = "switch-focus-between-floating-and-tiling";

          # Toggle tabbed column display mode.
          # Windows in this column will appear as vertical tabs,
          # rather than stacked on top of each other.
          "Mod+W" = "toggle-column-tabbed-display";

          # The following binds move the focused window in and out of a column.
          # If the window is alone, they will consume it into the nearby column to the side.
          # If the window is already in a column, they will expel it out.
          "Mod+BracketLeft" = "consume-or-expel-window-left";
          "Mod+BracketRight" = "consume-or-expel-window-right";
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
