{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../common
    ../common/wayland-wm

    ./basic-binds.nix
    # ./hyprbars.nix
  ];

  xdg.portal = {
    extraPortals = lib.mkForce [
      pkgs.inputs.hyprland.xdg-desktop-portal-hyprland
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [pkgs.inputs.hyprland.hyprland];
  };

  home.packages = with pkgs; [
    inputs.hyprwm-contrib.grimblast
    # hyprslurp
    # hyprpicker
    hyprcursor
    inputs.rose-pine-hyprcursor.default
  ];

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      splash_offset = 2.0;

      preload = [config.wallpaper];

      wallpaper = [
        ",${config.wallpaper}"
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.inputs.hyprland.hyprland.override {
      # enableNvidiaPatches = true;
      enableXWayland = true;
    };
    systemd = {
      enable = true;
      # Same as default, but stop graphical-session too
      extraCommands = lib.mkBefore [
        "systemctl --user stop graphical-session.target"
        "systemctl --user start hyprland-session.target"
      ];
    };

    settings = {
      env = [
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
      ];
      general = {
        gaps_in = 5;
        gaps_out = 0;
        border_size = 1;
        "col.active_border" = "0xff${config.colorscheme.colors.base0A}";
        "col.inactive_border" = "0xff${config.colorscheme.colors.base02}";
      };
      cursor = {
        inactive_timeout = 4;
      };
      # workspace_swipe = true;
      # workspace_swipe_fingers = 4;
      group = {
        "col.border_active" = "0xff${config.colorscheme.colors.base0B}";
        "col.border_inactive" = "0xff${config.colorscheme.colors.base04}";
        groupbar = {
          font_size = 11;
        };
      };
      input = {
        kb_layout = "gb";
        touchpad = {
          natural_scroll = true;
          disable_while_typing = false;
          drag_lock = true;
        };
      };
      dwindle.split_width_multiplier = 1.35;
      misc = {
        vfr = true;
        close_special_on_empty = true;
        # Unfullscreen when opening something
        new_window_takes_over_fullscreen = 2;
      };
      layerrule = [
        # "blur,waybar"
        # "ignorezero,waybar"
      ];
      windowrulev2 =
        [
          "opacity 1.0 override,initialTitle:(Discord Popout)"
          "opacity 1.0 override,class:(firefox),title:(.*)(- YouTube — Mozilla Firefox)$"
          "float,title:^(klipr)$"
        ]
        ++ ( # quick float by class rules
          map (x: "float,class:^(${x})$")
          ["xdg-desktop-portal-gtk" "qalculate-gtk" "blender"]
        );
      blurls = [
        # "waybar"
      ];

      decoration = {
        active_opacity = 1.0;
        inactive_opacity = 0.75;
        fullscreen_opacity = 1.0;
        rounding = 5;
        blur = {
          enabled = true;
          size = 3;
          passes = 5;
          noise = 0.05;
          contrast = 0.7;
          brightness = 0.8172;
          vibrancy = 0.5;
          vibrancy_darkness = 0.0;
          new_optimizations = true;
          ignore_opacity = true;
        };
        shadow = {
          enabled = true;
          range = 12;
          render_power = 4;
          offset = "1 3";
          color = "0x44000000";
          color_inactive = "0x66000000";
        };
      };
      animations = {
        enabled = true;
        bezier = [
          "easein,0.11, 0, 0.5, 0"
          "easeout,0.5, 1, 0.89, 1"
          "easeinback,0.36, 0, 0.66, -0.56"
          "easeoutback,0.34, 1.56, 0.64, 1"
        ];

        animation = [
          "windowsIn,1,3,easeoutback,slide"
          "windowsOut,1,3,easeinback,slide"
          "windowsMove,1,3,easeoutback"
          "workspaces,1,2,easeoutback,slide"
          "fadeIn,1,3,easeout"
          "fadeOut,1,3,easein"
          "fadeSwitch,1,3,easeout"
          "fadeShadow,1,3,easeout"
          "fadeDim,1,3,easeout"
          "border,1,3,easeout"
        ];
      };

      # exec = [
      #   "${pkgs.swaybg}/bin/swaybg -i ${config.wallpaper} --mode fill"
      # ];
      exec-once =
        [
          "hyprctl setcursor rose-pine-hyprcursor 35"
        ]
        ++ (lib.optionals config.programs.hyprlock.enable [
          "${pkgs.hyprlock}/bin/hyprlock --immediate"
        ])
        ++ (lib.optionals config.services.hyprpaper.enable [
          "${config.services.hyprpaper.package}/bin/hyprlock"
        ])
        ++ (lib.optionals config.services.hypridle.enable [
          "${pkgs.hypridle}/bin/hypridle"
        ]);

      bind = let
        swaylock = "${config.programs.swaylock.package}/bin/swaylock";
        playerctl = "${config.services.playerctld.package}/bin/playerctl";
        playerctld = "${config.services.playerctld.package}/bin/playerctld";
        makoctl = "${config.services.mako.package}/bin/makoctl";
        wofi = "${config.programs.wofi.package}/bin/wofi";
        # pass-wofi = "${pkgs.pass-wofi.override {
        #   pass = config.programs.password-store.package;
        # }}/bin/pass-wofi";

        grimblast = "${pkgs.inputs.hyprwm-contrib.grimblast}/bin/grimblast";
        pactl = "${pkgs.pulseaudio}/bin/pactl";
        tly = "${pkgs.tly}/bin/tly";
        gtk-play = "${pkgs.libcanberra-gtk3}/bin/canberra-gtk-play";
        notify-send = "${pkgs.libnotify}/bin/notify-send";

        gtk-launch = "${pkgs.gtk3}/bin/gtk-launch";
        xdg-mime = "${pkgs.xdg-utils}/bin/xdg-mime";
        defaultApp = type: "${gtk-launch} $(${xdg-mime} query default ${type})";

        terminal = config.home.sessionVariables.TERMINAL;
        browser = defaultApp "x-scheme-handler/https";
        editor = defaultApp "text/plain";
      in
        [
          # Program bindings
          "SUPER,Return,exec,${terminal}"
          "SUPER,e,exec,${editor}"
          "SUPER,v,exec,${editor}"
          "SUPER_SHIFT,Return,exec,${browser}"
          # Brightness control (only works if the system has lightd)
          ",XF86MonBrightnessUp,exec,light -A 10"
          ",XF86MonBrightnessDown,exec,light -U 10"
          # Volume
          ",XF86AudioRaiseVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ +5%"
          ",XF86AudioLowerVolume,exec,${pactl} set-sink-volume @DEFAULT_SINK@ -5%"
          ",XF86AudioMute,exec,${pactl} set-sink-mute @DEFAULT_SINK@ toggle"
          "SHIFT,XF86AudioMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
          ",XF86AudioMicMute,exec,${pactl} set-source-mute @DEFAULT_SOURCE@ toggle"
          # Screenshotting
          ",Print,exec,${grimblast} --notify --freeze copy output"
          "SHIFT,Print,exec,${grimblast} --notify --freeze copy active"
          "CONTROL,Print,exec,${grimblast} --notify --freeze copy screen"
          "SUPER,Print,exec,${grimblast} --notify --freeze copy area"
          "ALT,Print,exec,${grimblast} --notify --freeze copy area"
          ",Insert,exec,${grimblast} --notify --freeze copy output"
          "SHIFT,Insert,exec,${grimblast} --notify --freeze copy active"
          "CONTROL,Insert,exec,${grimblast} --notify --freeze copy screen"
          "SUPER,Insert,exec,${grimblast} --notify --freeze copy area"
          "ALT,Insert,exec,${grimblast} --notify --freeze copy area"
          # Tally counter
          "SUPER,z,exec,${notify-send} -t 1000 $(${tly} time) && ${tly} add && ${gtk-play} -i dialog-information" # Add new entry
          "SUPERCONTROL,z,exec,${notify-send} -t 1000 $(${tly} time) && ${tly} undo && ${gtk-play} -i dialog-warning" # Undo last entry
          "SUPERCONTROLSHIFT,z,exec,${tly} reset && ${gtk-play} -i complete" # Reset
          "SUPERSHIFT,z,exec,${notify-send} -t 1000 $(${tly} time)" # Show current time
        ]
        ++ (lib.optionals config.services.playerctld.enable [
          # Media control
          ",XF86AudioNext,exec,${playerctl} next"
          ",XF86AudioPrev,exec,${playerctl} previous"
          ",XF86AudioPlay,exec,${playerctl} play-pause"
          ",XF86AudioStop,exec,${playerctl} stop"
          "ALT,XF86AudioNext,exec,${playerctld} shift"
          "ALT,XF86AudioPrev,exec,${playerctld} unshift"
          "ALT,XF86AudioPlay,exec,systemctl --user restart playerctld"
        ])
        ++
        # Screen lock
        (lib.optionals config.programs.swaylock.enable [
          ",XF86Launch5,exec,${swaylock} -S --grace 2"
          ",XF86Launch4,exec,${swaylock} -S --grace 2"
          "SUPER,backspace,exec,${swaylock} -S --grace 2"
        ])
        ++
        # Notification manager
        (lib.optionals config.services.mako.enable [
          "SUPER,w,exec,${makoctl} dismiss"
        ])
        ++
        # Launcher
        (lib.optionals config.programs.wofi.enable [
          "SUPER,space,exec,${wofi} -S drun -w 1 -H 70%"
          "SUPER,x,exec,${wofi} -S run"
        ]);
      # ++ (lib.optionals config.programs.password-store.enable [
      #   ",Scroll_Lock,exec,${pass-wofi}" # fn+k
      #   ",XF86Calculator,exec,${pass-wofi}" # fn+f12
      #   "SUPER,semicolon,exec,pass-wofi"
      # ]));

      monitor =
        map
        (
          m: let
            resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
            position = "${toString m.x}x${toString m.y}";
          in "${m.name},${
            if m.enabled
            then "${resolution},${position},1,transform,${toString m.transform}"
            else "disable"
          }"
        )
        (config.monitors);

      workspace =
        map
        (
          m: "${m.name},${m.workspace}"
        )
        (lib.filter (m: m.enabled && m.workspace != null) config.monitors);
    };
    # This is order sensitive, so it has to come here.
    extraConfig = ''
      # Passthrough mode (e.g. for VNC)
      bind=SUPER,P,submap,passthrough
      submap=passthrough
      bind=SUPER,P,submap,reset
      submap=reset
    '';
  };
}
