{ config, pkgs, lib, ... }@inputs:
let
  user = "alan";
  monitors = [ "DP-2" "DVI-D-0" ];
in
{
  home.username = "${user}";
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "23.05";


  imports = [
    ../../home.nix # common home config
  ];

  home.packages = with pkgs; [
    playerctl
    nitrogen
    dolphin

    nushell

    lxappearance
    libsForQt5.qtstyleplugin-kvantum
    libsForQt5.qt5ct
    libsForQt5.kdegraphics-thumbnailers
    libsForQt5.qtstyleplugins

    libsForQt5.breeze-icons
    materia-kde-theme
    whitesur-kde
    whitesur-gtk-theme
    capitaine-cursors # cursor theme

    xdg-desktop-portal
    libsForQt5.xdg-desktop-portal-kde
    libsForQt5.kdialog

    fluent-kv

    chromium

    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    steam
    prismlauncher
    lutris

    # reverse engineering
    radare2
    iaito

    wine
    winetricks

    aseprite
    ldtk # 2d tilemap editor

    virt-manager
    postman
    mongodb-compass

    obs-studio
    gamemode

    barrier

    # discord-screenaudio # broken
  ];

  gtk.enable = true;
  # gtk.iconTheme.package = pkgs.papirus-icon-theme;
  # gtk.iconTheme.name = "Papirus-Dark";
  gtk.iconTheme.package = pkgs.libsForQt5.breeze-icons;
  gtk.iconTheme.name = "Adwaita";

  gtk.theme.package = pkgs.materia-theme;
  gtk.theme.name = "Materia-dark-compact";

  qt.enable = true;
  # qt.platformTheme = "kvantum";
  # qt.style.package = pkgs.materia-theme;
  # qt.style.name = "Materia-dark-compacto";
  # qt.style.name = "kvantum";

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=FluentDark
  '';

  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    # GTK_USE_PORTAL = 1;
  };


  programs.feh.enable = true;
  programs.pywal.enable = true;

  programs.rofi = {
    enable = true;
    plugins = [ pkgs.rofi-calc ];
    extraConfig = {

      modi = "drun,ssh";
    };
    theme."*" =
      let
        inherit (config.lib.formats.rasi) mkLiteral;
      in
      {
        text-color = mkLiteral "@foreground";
      };
    theme."@import" = lib.mkForce "${config.xdg.cacheHome}/wal/colors-rofi-light.rasi";
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  services.deadd-notification-center = {
    enable = true;
  };

  services.kdeconnect = {
    enable = true;
  };


  services.picom = {
    enable = true;
    backend = "glx";
    shadow = false;
    menuOpacity = 0.9;
    inactiveOpacity = 1.0;
    vSync = false;
    settings = {
      # glx-no-stencil = true;
      # glx-copy-from-front = true;
      # glx-swap-method = 1;
      # xrender-sync-fence = true;
      blur = {
        method = "dual_kawase";
        strength = 10;
      };
      # blur-background-exclude = ''name *?= "polybar"'';
      wintypes = {
        tooltip = {
          fade = true;
          shadow = false;
          opacity = 0.75;
        };
        utility = { shadow = false; };
      };
    };
  };

  programs.autorandr = {
    enable = true;
    profiles = {
      "main" = {
        fingerprint = {
          DVI-D-0 = "00ffffffffffff000469e12401010101241b010380351e78ea9de5a654549f260d5054b7ef00714f8180814081c081009500b3000101023a801871382d40582c4500132b2100001e000000fd0032961ea021000a202020202020000000fc0056473234380a20202020202020000000ff0048394c4d51533032383734330a01df020104008a4d80a070382c4030203500132b2100001afe5b80a07038354030203500132b2100001a866f80a07038404030203500132b2100001afc7e80887038124018203500132b2100001e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb";
          DP-2 = "00ffffffffffff000469a42401010101241b0104a5351e783a9de5a654549f260d5054b7ef00714f8180814081c081009500b3000101023a801871382d40582c4500132b2100001e000000fd0032961ea021000a202020202020000000fc0056473234380a20202020202020000000ff0048394c4d51533032383732350a01a6020318f14b900504030201111213141f2309070783010000023a801871382d40582c4500132b2100001e8a4d80a070382c4030203500132b2100001afe5b80a07038354030203500132b2100001a866f80a07038404030203500132b2100001afc7e80887038124018203500132b2100001e0000000000000000000000000073";
        };
        config = {
          DVI-D-0 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "144.00";
          };
          DP-2 = {
            enable = true;
            crtc = 1;
            position = "1920x0";
            mode = "1920x1080";
            rate = "144.00";
          };
        };
      };
      "left-vertical" = {
        fingerprint = {
          DVI-D-0 = "00ffffffffffff000469e12401010101241b010380351e78ea9de5a654549f260d5054b7ef00714f8180814081c081009500b3000101023a801871382d40582c4500132b2100001e000000fd0032961ea021000a202020202020000000fc0056473234380a20202020202020000000ff0048394c4d51533032383734330a01df020104008a4d80a070382c4030203500132b2100001afe5b80a07038354030203500132b2100001a866f80a07038404030203500132b2100001afc7e80887038124018203500132b2100001e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb";
          DP-2 = "00ffffffffffff000469a42401010101241b0104a5351e783a9de5a654549f260d5054b7ef00714f8180814081c081009500b3000101023a801871382d40582c4500132b2100001e000000fd0032961ea021000a202020202020000000fc0056473234380a20202020202020000000ff0048394c4d51533032383732350a01a6020318f14b900504030201111213141f2309070783010000023a801871382d40582c4500132b2100001e8a4d80a070382c4030203500132b2100001afe5b80a07038354030203500132b2100001a866f80a07038404030203500132b2100001afc7e80887038124018203500132b2100001e0000000000000000000000000073";
        };
        config = {
          DVI-D-0 = {
            enable = true;
            crtc = 0;
            position = "0x0";
            rotate = "left";
            mode = "1920x1080";
            rate = "144.00";
          };
          DP-2 = {
            enable = true;
            crtc = 1;
            primary = true;
            position = "1080x600";
            mode = "1920x1080";
            rate = "144.00";
          };
        };
      };
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      font_size = "11";
      background_opacity = "0.85";
    };
  };

  services.polybar = import ./polybar { inherit monitors; inherit pkgs; inherit config; };
  xdg.configFile.i3 = {
    source = ./i3;
    recursive = true;
  };
  xsession.windowManager.i3 =
    let
      alt = "Mod1";
      # numlock = "Mod2";
      # <unset> = "Mod3" ;
      super = "Mod4";
    in
    {
      enable = true;
      config = rec {
        terminal = "${pkgs.kitty}/bin/kitty";
        menu = "${config.programs.rofi.finalPackage}/bin/rofi";

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
            { class = "mag-text"; }
            { class = "basics"; }
            { title = "rust-voice"; }
            { class = "client"; }
          ];
        };

        window = {
          hideEdgeBorders = "both";
          commands = [{
            criteria = { class = ".*"; };
            command = "border pixel 1";
          }];
        };

        focus = {
          mouseWarping = true;
          followMouse = true;
        };

        gaps = {
          inner = 5;
          top = -5;
        };

        startup = [
          { command = "~/.config/i3/startup.sh"; }
        ];

        assigns = {
          "9" = [{ class = "^discord$"; } { class = "^telegram-desktop$"; }];
        };

        keybindings = with pkgs; {
          "Print" = "exec ${flameshot}/bin/flameshot full -c";
          "Shift+Insert" = "exec ${flameshot}/bin/flameshot gui -r | ${xclip}/bin/xclip -selection clipboard -t image/png";
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+Shift+Return" = "exec ${firefox}/bin/firefox";
          "${modifier}+c" = "exec ${menu} -show calc -modi calc -no-show-match -no-sort -calc-command \"echo -n '{result}' | xclip -selection clipboard\"";
          "${modifier}+Shift+c" = "exec ${gnome.zenity}/bin/zenity --calendar";

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

          "${modifier}+x" = "exec ~/.config/i3/keepass.sh";

          "${modifier}+r" = ''mode "resize"'';

          "XF86AudioRaiseVolume" = "exec amixer -q set Master 5%+ unmute";
          "XF86AudioLowerVolume" = "exec amixer -q set Master 5%- unmute";
          "XF86AudioMute" = "exec amixer -q set Master toggle";
          "${modifier}+XF86AudioRaiseVolume" = "exec amixer -q set Master 1%+ unmute && pkill -RTMIN+1 i3blocks";
          "${modifier}+XF86AudioLowerVolume" = "exec amixer -q set Master 1%- unmute && pkill -RTMIN+1 i3blocks";
          "XF86AudioPlay" = "exec playerctl play";
          "XF86AudioPause" = "exec playerctl pause";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
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
          "${modifier}+0" = "workspace 10";
          "${modifier}+Shift+1" = "move container to workspace 1; workspace 1";
          "${modifier}+Shift+2" = "move container to workspace 2; workspace 2";
          "${modifier}+Shift+3" = "move container to workspace 3; workspace 3";
          "${modifier}+Shift+4" = "move container to workspace 4; workspace 4";
          "${modifier}+Shift+5" = "move container to workspace 5; workspace 5";
          "${modifier}+Shift+6" = "move container to workspace 6; workspace 6";
          "${modifier}+Shift+7" = "move container to workspace 7; workspace 7";
          "${modifier}+Shift+8" = "move container to workspace 8; workspace 8";
          "${modifier}+Shift+9" = "move container to workspace 9; workspace 9";
          "${modifier}+Shift+0" = "move container to workspace 10; workspace 10";


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
          "${modifier}+Shift+F1" = "move container to workspace 11; workspace 11";
          "${modifier}+Shift+F2" = "move container to workspace 12; workspace 12";
          "${modifier}+Shift+F3" = "move container to workspace 13; workspace 13";
          "${modifier}+Shift+F4" = "move container to workspace 14; workspace 14";
          "${modifier}+Shift+F5" = "move container to workspace 15; workspace 15";
          "${modifier}+Shift+F6" = "move container to workspace 16; workspace 16";
          "${modifier}+Shift+F7" = "move container to workspace 17; workspace 17";
          "${modifier}+Shift+F8" = "move container to workspace 18; workspace 18";
          "${modifier}+Shift+F9" = "move container to workspace 19; workspace 19";
          "${modifier}+Shift+F10" = "move container to workspace 20; workspace 20";
          "${modifier}+Shift+F11" = "move container to workspace 21; workspace 21";
          "${modifier}+Shift+F12" = "move container to workspace 22; workspace 22";
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
          map (x: { output = "DP-2"; workspace = toString x; }) [ 1 2 3 4 5 6 7 8 9 10 ] ++
          map (x: { output = "DVI-D-0"; workspace = toString x; }) [ 11 12 13 14 15 16 17 18 19 20 21 22 ]
        ;

        # colors = let
        #   bgColor = "#2f343f";
        #   inactiveBgColor = "#2f343f";
        #   inactiveBorderColor = "#585c65";
        #   textColor = "#f3f4f5";
        #   inactiveTextColor = "#676e7d";
        #   urgentBgColor = "#e53935";
        #   indicatorColor = "#a0a0a0";
        # in {
        #   focused = {
        #     border = bgColor;
        #     background = bgColor;
        #     text = textColor;
        #     indicator = indicatorColor;
        #     childBorder = "#285577";
        #   };
        #   unfocused = {
        #     border = inactiveBorderColor;
        #     background = inactiveBgColor;
        #     text = inactiveTextColor;
        #     indicator = indicatorColor;
        #     childBorder = "#222222";
        #   };
        #   focusedInactive = {
        #     border = inactiveBorderColor;
        #     background = inactiveBgColor;
        #     text = inactiveTextColor;
        #     indicator = indicatorColor;
        #     childBorder = "#5f676a";
        #   };
        #   urgent = {
        #     border = urgentBgColor;
        #     background = urgentBgColor;
        #     text = textColor;
        #     indicator = indicatorColor;
        #     childBorder = "#900000";
        #   };
        # };
      };
      extraConfig = ''
    '';
    };

}
