{
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
  flake.modules.hjem.niri = {
    # rum.programs.niri = {
    #   enable = true;
    #   binds =
    #     {
    #       "Mod+Slash" = {
    #         action = "show-hotkey-overlay";
    #         parameters = {
    #           hotkey-overlay-title = "Cheatsheet";
    #         };
    #       };
    #
    #       "Mod+Return" = {
    #         span = ["alacritty"];
    #         parameters = {
    #           hotkey-overlay-title = "Open Terminal";
    #         };
    #       };
    #       "Mod+Shift+Return" = {
    #         span = ["firefox"];
    #         parameters = {
    #           hotkey-overlay-title = "Open Browser";
    #         };
    #       };
    #
    #       "Mod+Space" = {
    #         span = ["walker"];
    #         parameters = {
    #           hotkey-overlay-title = "App Launcher";
    #         };
    #       };
    #     }
    #     // builtins.mapAttrs (_name: value: {action = value;}) {
    #       "Mod+Left" = "focus-column-left";
    #       "Mod+Down" = "focus-window-down";
    #       "Mod+Up" = "focus-window-up";
    #       "Mod+Right" = "focus-column-right";
    #       "Mod+J" = "focus-window-or-workspace-down";
    #       "Mod+K" = "focus-window-or-workspace-up";
    #       "Mod+H" = "focus-column-left";
    #       "Mod+L" = "focus-column-right";
    #     }
    #     // builtins.mapAttrs (_name: value: {
    #       parameters = {allow-when-locked = true;};
    #       spawn = value;
    #     }) {
    #       "XF86AudioRaiseVolume" = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];
    #
    #       "XF86AudioLowerVolume" = ["wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"];
    #       "XF86AudioMute" = ["wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"];
    #       "XF86AudioMicMute" = ["wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"];
    #
    #       "XF86AudioPlay" = ["noctalia-shell ipc call media playPause"];
    #       "XF86AudioNext" = ["noctalia-shell ipc call media next"];
    #       "XF86AudioPrev" = ["noctalia-shell ipc call media previous"];
    #
    #       "XF86MonBrightnessUp" = ["brightnessctl" "--class=backlight" "set" "+10%"];
    #       "XF86MonBrightnessDown" = ["brightnessctl" "--class=backlight" "set" "10%-"];
    #     };
    # };
  };
}
