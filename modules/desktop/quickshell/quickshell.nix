{inputs, ...}: {
  flake.modules.hjem.quickshell = {
    pkgs,
    osConfig,
    lib,
    ...
  }: let
    quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

    palette = osConfig.theme.colors;
    inherit (osConfig.theme) fonts;

    # Pick the accent from the palette instead of a fixed slot: some base16
    # schemes (e.g. black-metal) only put chroma in a few of the base08-base0F
    # accent slots and leave the rest gray. Ranking by HSL saturation keeps the
    # accent vivid whichever scheme is active. basix hands us `#rrggbb` only, so
    # decode channels here rather than expecting precomputed rgb attrs.
    hexDigit = c:
      {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
      }
      .${
        c
      };
    channel = key: off: let
      h = lib.toLower (lib.removePrefix "#" palette.${key});
    in
      hexDigit (builtins.substring off 1 h) * 16 + hexDigit (builtins.substring (off + 1) 1 h);
    accentKeys = ["base08" "base09" "base0A" "base0B" "base0C" "base0D" "base0E" "base0F"];
    saturation = key: let
      r = channel key 0;
      g = channel key 2;
      b = channel key 4;
      maxc = lib.max r (lib.max g b);
      minc = lib.min r (lib.min g b);
      sum = maxc + minc; # 2*lightness on the 0-510 scale
    in
      if maxc == minc
      then 0.0
      else
        (maxc - minc)
        * 1.0
        / (
          if sum <= 255
          then sum
          else 510 - sum
        );
    ranked = lib.sort (a: b: a.sat > b.sat) (map (k: {
        key = k;
        sat = saturation k;
      })
      accentKeys);
    accentKey = (builtins.elemAt ranked 0).key;
    accentAltKey = (builtins.elemAt ranked 1).key;

    baseKeys = [
      "base00"
      "base01"
      "base02"
      "base03"
      "base04"
      "base05"
      "base06"
      "base07"
      "base08"
      "base09"
      "base0A"
      "base0B"
      "base0C"
      "base0D"
      "base0E"
      "base0F"
    ];
    baseProps = lib.concatMapStringsSep "\n" (k: ''readonly property color ${k}: "${palette.${k}}";'') baseKeys;

    # Generated from the theme module; edit the palette/fonts in modules/desktop/theme, not here.
    themeQml = ''
      pragma Singleton
      import Quickshell
      import QtQuick

      // Auto-generated from the theme module (base16 scheme + fonts). Do not edit by hand.
      Singleton {
          ${baseProps}

          // Semantic aliases following base16 conventions.
          readonly property color background: base00;
          readonly property color surface: base01;
          readonly property color selection: base02;
          readonly property color muted: base03;
          readonly property color foreground: base05;
          // accent/accentAlt are the two most saturated palette slots (scheme-agnostic).
          readonly property color accent: ${accentKey};
          readonly property color accentAlt: ${accentAltKey};
          readonly property color red: base08;
          readonly property color orange: base09;
          readonly property color yellow: base0A;
          readonly property color green: base0B;
          readonly property color cyan: base0C;
          readonly property color blue: base0D;
          readonly property color magenta: base0E;

          readonly property string fontFamily: "${fonts.sansSerif.name}";
          readonly property string monoFamily: "${fonts.monospace.name}";
          readonly property int fontSize: ${toString fonts.sizes.desktop};
      }
    '';
  in {
    packages = [quickshell];

    xdg.config.files = {
      # Loaded via `quickshell -c config` (see ExecStart), i.e.
      # $XDG_CONFIG_HOME/quickshell/config/shell.qml. Components and the Style
      # singleton are committed; Theme is generated from the theme module below.
      "quickshell/config/shell.qml".source = ./config/shell.qml;
      "quickshell/config/qmldir".source = ./config/qmldir;
      "quickshell/config/Bar.qml".source = ./config/Bar.qml;
      "quickshell/config/Section.qml".source = ./config/Section.qml;
      "quickshell/config/Tray.qml".source = ./config/Tray.qml;
      "quickshell/config/Media.qml".source = ./config/Media.qml;
      "quickshell/config/Battery.qml".source = ./config/Battery.qml;
      "quickshell/config/Button.qml".source = ./config/Button.qml;
      "quickshell/config/Brightness.qml".source = ./config/Brightness.qml;
      "quickshell/config/Volume.qml".source = ./config/Volume.qml;
      "quickshell/config/VolumeControls.qml".source = ./config/VolumeControls.qml;
      "quickshell/config/VolumeSlider.qml".source = ./config/VolumeSlider.qml;
      "quickshell/config/Popup.qml".source = ./config/Popup.qml;
      "quickshell/config/MenuView.qml".source = ./config/MenuView.qml;
      "quickshell/config/Notifications.qml".source = ./config/Notifications.qml;
      "quickshell/config/Style.qml".source = ./config/Style.qml;
      "quickshell/config/Theme.qml".text = themeQml;
    };

    systemd.services.quickshell = {
      description = "Quickshell desktop shell";
      documentation = ["https://quickshell.org"];
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      bindsTo = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${quickshell}/bin/quickshell -c config";
        Restart = "on-failure";
        RestartSec = "2";
        Slice = "session.slice";
      };
    };
  };
}
