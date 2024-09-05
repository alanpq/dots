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
      input-field = [
        {
          size = "250, 50";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = color {c=colors.base01;};
          inner_color = color {c=colors.base00;};
          font_color = color {c=colors.base07; alpha=0.5;};
          fail_color = color {c=colors.base08;};
          placeholder_text = "password";
          font_family = "FiraSans Light";
          fade_on_empty = false;
          hide_input = false;
          position = "0, 200";
          halign = "center";
          valign = "bottom";
        }
      ];

      label = [
        {
          text = "cmd[update:60000] echo \"<b><big> $(date +\"%H:%M\") </big></b>\"";
          color = color {c = colors.base07; alpha = 0.7;};
          font_size = 94;
          font_family = "FiraSans Regular";

          position = "0, -150";
          halign = "center";
          valign = "top";
        }
        {
          text = "cmd[update:18000000] echo \"\"$(date +'%A, %-d %B %Y')\"\"";
          color = color {c = colors.base07; alpha = 0.7;};
          font_size = 18;
          font_family = "FiraSans Light";

          position = "0, -285";
          halign = "center";
          valign = "top";
        }
      ];
    };
  };
}
