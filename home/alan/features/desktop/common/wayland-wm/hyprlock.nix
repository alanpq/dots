{ config, pkgs, inputs, ... }:
let
  inherit (config.colorscheme) colors;
  inherit (inputs.nix-colors.lib.conversions) hexToRGBString;

  color = {c, alpha ? 1.0}: "rgba(${hexToRGBString "," c},${toString alpha})";
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        grace = 0.5;
      };
      background = [
        {
          path = config.wallpaper;
          blur_size = 3;
          blur_passes = 5;
          noise = 0.05;
          contrast = 0.7;
          brightness = 0.8172;
          vibrancy = 0.5;
          vibrancy_darkness = 0.0;
        }
      ];
      image = [
        {
          path = "${../avatar.png}";
          size = 120;
          rounding = -1;
          position = "0, 0";
          halign = "center";
          valign = "center";

          border_size = 1;
          border_color = color {c=colors.base01;};
        }
      ];
      input-field = [
        {
          size = "200, 35";
          outline_thickness = 1;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = color {c=colors.base01;};
          inner_color = color {c=colors.base00;};
          font_color = color {c=colors.base07; alpha=0.5;};
          check_color = color {c=colors.base09;};
          fail_color = color {c=colors.base0C;};
          placeholder_text = "enter password";
          font_family = "FiraSans Light";
          fade_on_empty = false;
          hide_input = false;
          position = "0, -100";
          halign = "center";
          valign = "center";
        }
      ];

      label = [
        { # HH:MM
          text = "cmd[update:60000] echo \"<b><big> $(date +\"%H:%M\") </big></b>\"";
          color = color {c = colors.base07; alpha = 0.7;};
          font_size = 110;
          font_family = "FiraSans Regular";

          position = "0, -150";
          halign = "center";
          valign = "top";
        }
        { # Date
          text = "cmd[update:18000000] echo \"\"$(date +'%A, %-d %B %Y')\"\"";
          color = color {c = colors.base07; alpha = 0.7;};
          font_size = 20;
          font_family = "FiraSans Light";

          position = "0, -300";
          halign = "center";
          valign = "top";
        }
        {

        }
      ];
    };
  };
}
