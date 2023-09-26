{ config, pkgs, lib, ... }:
let user = "alan";
in {
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "23.05";


  imports = [
    ../../home.nix # common home config
  ];

  home.packages = with pkgs; [
    discord
  ];

  programs.autorandr = {
    enable = true;
    profiles = {
      "horizontal" = {
        fingerprint = {
          DVI = "00ffffffffffff000469e12401010101241b010380351e78ea9de5a654549f260d5054b7ef00714f8180814081c081009500b3000101023a801871382d40582c4500132b2100001e000000fd0032961ea021000a202020202020000000fc0056473234380a20202020202020000000ff0048394c4d51533032383734330a01df020104008a4d80a070382c4030203500132b2100001afe5b80a07038354030203500132b2100001a866f80a07038404030203500132b2100001afc7e80887038124018203500132b2100001e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb";
          DP = "00ffffffffffff000469a42401010101241b0104a5351e783a9de5a654549f260d5054b7ef00714f8180814081c081009500b3000101023a801871382d40582c4500132b2100001e000000fd0032961ea021000a202020202020000000fc0056473234380a20202020202020000000ff0048394c4d51533032383732350a01a6020318f14b900504030201111213141f2309070783010000023a801871382d40582c4500132b2100001e8a4d80a070382c4030203500132b2100001afe5b80a07038354030203500132b2100001a866f80a07038404030203500132b2100001afc7e80887038124018203500132b2100001e0000000000000000000000000073";
        };
        config = {
          DVI = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "144.00";
          };
          DP = {
            enable = true;
            crtc = 1;
            position = "1920x0";
            mode = "1920x1080";
            rate = "144.00";
          };
        };
      };
    };
  };

  xsession.windowManager.i3 = let
    alt = "Mod1";
    # numlock = "Mod2";
    # <unset> = "Mod3" ;
    super = "Mod4";
  in {
    enable = true;
    config = rec {
      terminal = "${pkgs.kitty}/bin/kitty";
      menu = "${pkgs.rofi}/bin/rofi";

      fonts = {
        names = [ "monospace" ];
        size = 9.0;
      };

      modifier = super;

      floating = {
        modifier = "${modifier}";
        criteria = [
          { class = "Pavucontrol"; }
          { class = "Calendar"; }
          { class = "zoom"; }
          { title = "Zoom Meeting"; }
        ];
      };

      window = {
        hideEdgeBorders = "both";
        commands = [{
          criteria = { class = ".*"; };
          command = "border pixel 0";
        }];
      };

      focus = {
        mouseWarping = false;
        followMouse = true;
      };

      gaps = {
        inner = 15;
        top = -5;
      };

      startup = [{ command = "${pkgs.nitrogen}/bin/nitrogen --restore"; }];

      assigns = {
        "9" = [ { class = "^discord$"; } { class = "^telegram-desktop$"; } ];
      };

      keybindings = with pkgs; {
        "Print" = "exec ${flameshot}/bin/flameshot full -c";
        "Shift+Print" = "exec ${flameshot}/bin/flameshot gui -r | ${xclip}/bin/xclip -selection clipboard -t image/png";
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+c" = "exec ${gnome.zenity}/bin/zenity --calendar";
        
        "${modifier}+q" = "kill";
        "${modifier}+Shift+r" = "restart";
        
        "${modifier}+space" = "exec ${menu} -show drun";
        "${alt}+Tab" = "exec ${menu} -show window";

        # "${modifier}+Shift+c"
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        "${modifier}+h" = "split h";
        "${modifier}+v" = "split v";

        "${modifier}+f" = "fullscreen toggle";

        "${modifier}+Shift+s" = "layout stacking";
        "${modifier}+Shift+w" = "layout tabbed";
        "${modifier}+Shift+e" = "layout toggle split";

        "${modifier}+Shift+space" = "floating toggle";

        # "${modifier}+a" = "focus parent";
        # "${modifier}+d" = "focus"

        "Control+${alt}+l" = "exec dm-tool lock";

        "${modifier}+r" = ''mode "resize"'';

        "XF86AudioRaiseVolume" = "exec amixer -q set Master 5%+ unmute";
        "XF86AudioLowerVolume" = "exec amixer -q set Master 5%- unmute";
        "XF86AudioMute" = "exec amixer -q set Master toggle";
        "${modifier}+XF86AudioRaiseVolume" = "exec amixer -q set Master 1%+ unmute && pkill -RTMIN+1 i3blocks";
        "${modifier}+XF86AudioLowerVolume" = "exec amixer -q set Master 1%- unmute && pkill -RTMIN+1 i3blocks";
        "XF86AudioPlay" = "exec playerctl play";
        "${modifier}+Ctrl+space" = "exec playerctl play-pause";

        "${modifier}+slash" = "exec splatmoji copy";
        
        "${modifier}+1" = "workspace 1";
        "${modifier}+2" = "workspace 2";
        "${modifier}+3" = "workspace 3";
        "${modifier}+4" = "workspace 4";
        "${modifier}+5" = "workspace 5";
        "${modifier}+6" = "workspace 6";
        "${modifier}+7" = "workspace 7";
        "${modifier}+8" = "workspace 8";
        "${modifier}+9" = "workspace 9";
        "${modifier}+10" = "workspace 10";
        "${modifier}+Shift+1" = "move container to workspace 1";
        "${modifier}+Shift+2" = "move container to workspace 2";
        "${modifier}+Shift+3" = "move container to workspace 3";
        "${modifier}+Shift+4" = "move container to workspace 4";
        "${modifier}+Shift+5" = "move container to workspace 5";
        "${modifier}+Shift+6" = "move container to workspace 6";
        "${modifier}+Shift+7" = "move container to workspace 7";
        "${modifier}+Shift+8" = "move container to workspace 8";
        "${modifier}+Shift+9" = "move container to workspace 9";
        "${modifier}+Shift+0" = "move container to workspace 10";


        "${modifier}+F1" = "workspace 11";
        "${modifier}+F2" = "workspace 12";
        "${modifier}+F3" = "workspace 13";
        "${modifier}+F4" = "workspace 14";
        "${modifier}+F5" = "workspace 15";
        "${modifier}+F6" = "workspace 16";
        "${modifier}+F7" = "workspace 17";
        "${modifier}+F8" = "workspace 18";
        "${modifier}+F9" = "workspace 19";
        "${modifier}+F10" = "workspace 20";
        "${modifier}+F11" = "workspace 21";
        "${modifier}+F12" = "workspace 22";
        "${modifier}+Shift+F1" = "move container to workspace 11";
        "${modifier}+Shift+F2" = "move container to workspace 12";
        "${modifier}+Shift+F3" = "move container to workspace 13";
        "${modifier}+Shift+F4" = "move container to workspace 14";
        "${modifier}+Shift+F5" = "move container to workspace 15";
        "${modifier}+Shift+F6" = "move container to workspace 16";
        "${modifier}+Shift+F7" = "move container to workspace 17";
        "${modifier}+Shift+F8" = "move container to workspace 18";
        "${modifier}+Shift+F9" = "move container to workspace 19";
        "${modifier}+Shift+F10" = "move container to workspace 20";
        "${modifier}+Shift+F11" = "move container to workspace 21";
        "${modifier}+Shift+F12" = "move container to workspace 22";
      };

      modes = {
        resize = {
          "Left" = "resize shrink width 10 px or 10 ppt";
          "Down" = "resize grow height 10 px or 10 ppt";
          "Up" = "resize shrink height 10 px or 10 ppt";
          "Right" = "resize grow width 10 px or 10 ppt";

          # back to normal: Enter or Escape
          "Return" = ''mode "default"'';
          "Escape" = ''mode "default"'';
        };
      };

      bars = [
        # TODO: test empty
      ];

      workspaceOutputAssign = 
        map (x: {output = "DVI-D-0"; workspace=toString x;}) [1 2 3 4 5 6 7 8 9 10] ++
        map (x: {output = "DP-2"; workspace=toString x;}) [11 12 13 14 15 16 17 18 19 20 21 22]
      ;

      colors = let
        bgColor = "#2f343f";
        inactiveBgColor = "#2f343f";
        inactiveBorderColor = "#585c65";
        textColor = "#f3f4f5";
        inactiveTextColor = "#676e7d";
        urgentBgColor = "#e53935";
        indicatorColor = "#a0a0a0";
      in {
        focused = {
          border = bgColor;
          background = bgColor;
          text = textColor;
          indicator = indicatorColor;
          childBorder = "#285577";
        };
        unfocused = {
          border = inactiveBorderColor;
          background = inactiveBgColor;
          text = inactiveTextColor;
          indicator = indicatorColor;
          childBorder = "#222222";
        };
        focusedInactive = {
          border = inactiveBorderColor;
          background = inactiveBgColor;
          text = inactiveTextColor;
          indicator = indicatorColor;
          childBorder = "#5f676a";
        };
        urgent = {
          border = urgentBgColor;
          background = urgentBgColor;
          text = textColor;
          indicator = indicatorColor;
          childBorder = "#900000";
        };
      };
    };
    extraConfig = ''
    '';
  };

}