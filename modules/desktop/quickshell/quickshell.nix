{inputs, ...}: {
  flake.modules.hjem.quickshell = {
    pkgs,
    osConfig,
    lib,
    ...
  }: let
    quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

    colors = osConfig.lib.stylix.colors.withHashtag;
    inherit (osConfig.stylix) fonts;

    # Pick the accent from the palette instead of a fixed slot: some base16
    # schemes (e.g. black-metal) only put chroma in a few of the base08-base0F
    # accent slots and leave the rest gray. Ranking by HSL saturation keeps the
    # accent vivid whichever scheme is active.
    palette = osConfig.lib.stylix.colors;
    accentKeys = ["base08" "base09" "base0A" "base0B" "base0C" "base0D" "base0E" "base0F"];
    saturation = key: let
      r = lib.toInt palette."${key}-rgb-r";
      g = lib.toInt palette."${key}-rgb-g";
      b = lib.toInt palette."${key}-rgb-b";
      maxc = lib.max r (lib.max g b);
      minc = lib.min r (lib.min g b);
      sum = maxc + minc; # 2*lightness on the 0-510 scale
    in
      if maxc == minc
      then 0.0
      else (maxc - minc) * 1.0 / (if sum <= 255 then sum else 510 - sum);
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
    baseProps = lib.concatMapStringsSep "\n" (k: ''readonly property color ${k}: "${colors.${k}}";'') baseKeys;

    # Generated from stylix; edit theme in modules/desktop/stylix, not here.
    themeQml = ''
      pragma Singleton
      import Quickshell
      import QtQuick

      // Auto-generated from stylix (base16 scheme + fonts). Do not edit by hand.
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
      # quickshell loads $XDG_CONFIG_HOME/quickshell/shell.qml by default.
      "quickshell/shell.qml".source = ./shell.qml;
      "quickshell/Theme.qml".text = themeQml;
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
        ExecStart = "${quickshell}/bin/quickshell";
        Restart = "on-failure";
        RestartSec = "2";
        Slice = "session.slice";
      };
    };
  };
}
