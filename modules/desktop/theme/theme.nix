{
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  flake-file.inputs.basix = {
    url = "github:notashelf/basix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.theme = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.theme;
    basixLib = inputs.basix.lib;

    scheme = inputs.basix.schemeData.${cfg.system}.${cfg.scheme};

    hex = key: basixLib.normalizeHex scheme.palette.${key};
    colors = lib.mapAttrs (_: c: "#" + basixLib.normalizeHex c) scheme.palette;

    # adw-gtk3 is a polished base theme; we only recolor it (see the hjem module
    # below) rather than shipping a hand-rolled theme.
    gtkThemeName =
      if cfg.polarity == "dark"
      then "adw-gtk3-dark"
      else "adw-gtk3";
    appFont = "${cfg.fonts.sansSerif.name} ${toString cfg.fonts.sizes.applications}";

    fontOption = mkOption {
      type = types.submodule {
        options = {
          package = mkOption {type = types.package;};
          name = mkOption {type = types.str;};
        };
      };
    };
  in {
    options.theme = {
      system = mkOption {
        type = types.enum ["base16" "base24"];
        default = "base16";
        description = "Basix scheme collection `scheme` is drawn from.";
      };
      scheme = mkOption {
        type = types.str;
        default = "chalk";
        description = "Basix scheme slug (see notashelf/basix `json/<system>`).";
      };
      colors = mkOption {
        type = types.attrsOf types.str;
        readOnly = true;
        description = "Selected scheme palette: base00-base0F as `#rrggbb`.";
      };
      polarity = mkOption {
        type = types.enum ["dark" "light"];
        default = "dark";
        description = "Light/dark hint; defaults to the scheme's variant.";
      };
      fonts = {
        serif = fontOption;
        sansSerif = fontOption;
        monospace = fontOption;
        emoji = fontOption;
        sizes = {
          applications = mkOption {
            type = types.int;
            default = 12;
          };
          desktop = mkOption {
            type = types.int;
            default = 10;
          };
          popups = mkOption {
            type = types.int;
            default = 10;
          };
          terminal = mkOption {
            type = types.int;
            default = 9;
          };
        };
      };
      cursor = {
        package = mkOption {type = types.package;};
        name = mkOption {type = types.str;};
        size = mkOption {
          type = types.int;
          default = 24;
        };
      };
      iconTheme = {
        package = mkOption {
          type = types.package;
          default = pkgs.papirus-icon-theme;
        };
        name = mkOption {
          type = types.str;
          default = "Papirus-Dark";
        };
      };
      gtk.enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Theme GTK apps: recolor adw-gtk3/libadwaita from the active palette
          (per-user gtk.css via hjem) and set the dconf dark preference.
        '';
      };
      qt.enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Theme Qt apps: Fusion style with a base16 QPalette (per-user
          qt5ct/qt6ct config via hjem) so they match GTK and the terminal.
        '';
      };
    };

    config = lib.mkMerge [
      {
        theme = {
          inherit colors;
          polarity = lib.mkDefault (
            if (scheme.variant or "dark") == "light"
            then "light"
            else "dark"
          );
          fonts = {
            serif = {
              package = lib.mkDefault pkgs.poppins;
              name = lib.mkDefault "Poppins";
            };
            sansSerif = {
              package = lib.mkDefault pkgs.poppins;
              name = lib.mkDefault "Poppins";
            };
            monospace = {
              package = lib.mkDefault pkgs.nerd-fonts.jetbrains-mono;
              name = lib.mkDefault "JetBrainsMono NF";
            };
            emoji = {
              package = lib.mkDefault pkgs.noto-fonts-color-emoji;
              name = lib.mkDefault "Noto Color Emoji";
            };
          };
          cursor = {
            package = lib.mkDefault pkgs.volantes-cursors;
            name = lib.mkDefault "volantes_cursors";
          };
        };

        fonts = {
          packages = lib.unique (map (f: f.package) [
            cfg.fonts.serif
            cfg.fonts.sansSerif
            cfg.fonts.monospace
            cfg.fonts.emoji
          ]);
          fontconfig.defaultFonts = {
            serif = [cfg.fonts.serif.name];
            sansSerif = [cfg.fonts.sansSerif.name];
            monospace = [cfg.fonts.monospace.name];
            emoji = [cfg.fonts.emoji.name];
          };
        };

        console.colors = map hex [
          "base00"
          "base08"
          "base0B"
          "base0A"
          "base0D"
          "base0E"
          "base0C"
          "base05"
          "base03"
          "base08"
          "base0B"
          "base0A"
          "base0D"
          "base0E"
          "base0C"
          "base07"
        ];

        environment.systemPackages = [cfg.cursor.package];
        environment.sessionVariables = {
          XCURSOR_THEME = cfg.cursor.name;
          XCURSOR_SIZE = toString cfg.cursor.size;
        };
      }

      (lib.mkIf cfg.gtk.enable {
        # libadwaita/GTK4 apps take their light/dark preference from dconf, not
        # from settings.ini or GTK_THEME. The per-user gtk.css (hjem module)
        # handles the actual recolor; this makes apps pick the dark variant and
        # feeds the same values to the settings portal.
        programs.dconf.enable = true;
        programs.dconf.profiles.user.databases = [
          {
            settings."org/gnome/desktop/interface" = {
              color-scheme =
                if cfg.polarity == "dark"
                then "prefer-dark"
                else "prefer-light";
              gtk-theme = gtkThemeName;
              icon-theme = cfg.iconTheme.name;
              cursor-theme = cfg.cursor.name;
              cursor-size = lib.gvariant.mkInt32 cfg.cursor.size;
              font-name = appFont;
              document-font-name = appFont;
              monospace-font-name = "${cfg.fonts.monospace.name} ${toString cfg.fonts.sizes.applications}";
            };
          }
        ];
      })

      (lib.mkIf cfg.qt.enable {
        # qt5ct themes Qt5 apps; qt6ct's libqt6ct.so registers the "qt5ct" key
        # too, so this single platformTheme covers Qt6 as well. The palette
        # lives in the per-user qt5ct/qt6ct config (hjem module).
        qt.enable = true;
        qt.platformTheme = "qt5ct";
      })
    ];
  };

  flake.modules.hjem.theme = {
    osConfig,
    pkgs,
    lib,
    ...
  }: let
    cfg = osConfig.theme;
    hexOf = k: lib.removePrefix "#" cfg.colors.${k};
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
    # Decimal channel of a palette slot; only base01 needs it (translucent
    # headerbar border below).
    chan = k: off: let
      h = hexOf k;
    in
      toString (hexDigit (builtins.substring off 1 h) * 16 + hexDigit (builtins.substring (off + 1) 1 h));
    gtkThemeName =
      if cfg.polarity == "dark"
      then "adw-gtk3-dark"
      else "adw-gtk3";
    appFont = "${cfg.fonts.sansSerif.name} ${toString cfg.fonts.sizes.applications}";

    # Recolor adw-gtk3 (GTK3) and libadwaita (GTK4) named colors from the active
    # base16 palette. Mirrors nix-community/stylix's gtk.css template.
    gtkCss = ''
      @define-color accent_color #${hexOf "base0D"};
      @define-color accent_bg_color #${hexOf "base0D"};
      @define-color accent_fg_color #${hexOf "base00"};
      @define-color destructive_color #${hexOf "base08"};
      @define-color destructive_bg_color #${hexOf "base08"};
      @define-color destructive_fg_color #${hexOf "base00"};
      @define-color success_color #${hexOf "base0B"};
      @define-color success_bg_color #${hexOf "base0B"};
      @define-color success_fg_color #${hexOf "base00"};
      @define-color warning_color #${hexOf "base0E"};
      @define-color warning_bg_color #${hexOf "base0E"};
      @define-color warning_fg_color #${hexOf "base00"};
      @define-color error_color #${hexOf "base08"};
      @define-color error_bg_color #${hexOf "base08"};
      @define-color error_fg_color #${hexOf "base00"};
      @define-color window_bg_color #${hexOf "base00"};
      @define-color window_fg_color #${hexOf "base05"};
      @define-color view_bg_color #${hexOf "base00"};
      @define-color view_fg_color #${hexOf "base05"};
      @define-color headerbar_bg_color #${hexOf "base01"};
      @define-color headerbar_fg_color #${hexOf "base05"};
      @define-color headerbar_border_color rgba(${chan "base01" 0}, ${chan "base01" 2}, ${chan "base01" 4}, 0.7);
      @define-color headerbar_backdrop_color @window_bg_color;
      @define-color headerbar_shade_color rgba(0, 0, 0, 0.07);
      @define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.07);
      @define-color sidebar_bg_color #${hexOf "base01"};
      @define-color sidebar_fg_color #${hexOf "base05"};
      @define-color sidebar_backdrop_color @window_bg_color;
      @define-color sidebar_shade_color rgba(0, 0, 0, 0.07);
      @define-color secondary_sidebar_bg_color @sidebar_bg_color;
      @define-color secondary_sidebar_fg_color @sidebar_fg_color;
      @define-color secondary_sidebar_backdrop_color @sidebar_backdrop_color;
      @define-color secondary_sidebar_shade_color @sidebar_shade_color;
      @define-color card_bg_color #${hexOf "base01"};
      @define-color card_fg_color #${hexOf "base05"};
      @define-color card_shade_color rgba(0, 0, 0, 0.07);
      @define-color dialog_bg_color #${hexOf "base01"};
      @define-color dialog_fg_color #${hexOf "base05"};
      @define-color popover_bg_color #${hexOf "base01"};
      @define-color popover_fg_color #${hexOf "base05"};
      @define-color popover_shade_color rgba(0, 0, 0, 0.07);
      @define-color shade_color rgba(0, 0, 0, 0.07);
      @define-color scrollbar_outline_color #${hexOf "base02"};
      @define-color blue_1 #${hexOf "base0D"};
      @define-color blue_2 #${hexOf "base0D"};
      @define-color blue_3 #${hexOf "base0D"};
      @define-color blue_4 #${hexOf "base0D"};
      @define-color blue_5 #${hexOf "base0D"};
      @define-color green_1 #${hexOf "base0B"};
      @define-color green_2 #${hexOf "base0B"};
      @define-color green_3 #${hexOf "base0B"};
      @define-color green_4 #${hexOf "base0B"};
      @define-color green_5 #${hexOf "base0B"};
      @define-color yellow_1 #${hexOf "base0A"};
      @define-color yellow_2 #${hexOf "base0A"};
      @define-color yellow_3 #${hexOf "base0A"};
      @define-color yellow_4 #${hexOf "base0A"};
      @define-color yellow_5 #${hexOf "base0A"};
      @define-color orange_1 #${hexOf "base09"};
      @define-color orange_2 #${hexOf "base09"};
      @define-color orange_3 #${hexOf "base09"};
      @define-color orange_4 #${hexOf "base09"};
      @define-color orange_5 #${hexOf "base09"};
      @define-color red_1 #${hexOf "base08"};
      @define-color red_2 #${hexOf "base08"};
      @define-color red_3 #${hexOf "base08"};
      @define-color red_4 #${hexOf "base08"};
      @define-color red_5 #${hexOf "base08"};
      @define-color purple_1 #${hexOf "base0E"};
      @define-color purple_2 #${hexOf "base0E"};
      @define-color purple_3 #${hexOf "base0E"};
      @define-color purple_4 #${hexOf "base0E"};
      @define-color purple_5 #${hexOf "base0E"};
      @define-color brown_1 #${hexOf "base0F"};
      @define-color brown_2 #${hexOf "base0F"};
      @define-color brown_3 #${hexOf "base0F"};
      @define-color brown_4 #${hexOf "base0F"};
      @define-color brown_5 #${hexOf "base0F"};
      @define-color light_1 #${hexOf "base05"};
      @define-color light_2 #${hexOf "base05"};
      @define-color light_3 #${hexOf "base05"};
      @define-color light_4 #${hexOf "base05"};
      @define-color light_5 #${hexOf "base05"};
      @define-color dark_1 #${hexOf "base05"};
      @define-color dark_2 #${hexOf "base05"};
      @define-color dark_3 #${hexOf "base05"};
      @define-color dark_4 #${hexOf "base05"};
      @define-color dark_5 #${hexOf "base05"};
    '';

    # Qt: Fusion style + a base16 QPalette so Qt5/Qt6 apps match GTK and the
    # terminal. The list is the 21 QPalette::ColorRole slots in enum order
    # (WindowText..PlaceholderText); qt5ct/qt6ct load this color scheme.
    qtArgb = k: "#ff${hexOf k}";
    qtRow = keys: lib.concatMapStringsSep ", " qtArgb keys;
    qtActive = [
      "base05"
      "base01"
      "base02"
      "base02"
      "base00"
      "base01"
      "base05"
      "base06"
      "base05"
      "base00"
      "base00"
      "base00"
      "base0D"
      "base00"
      "base0D"
      "base0E"
      "base01"
      "base00"
      "base01"
      "base05"
      "base04"
    ];
    qtDisabled = [
      "base03"
      "base01"
      "base02"
      "base02"
      "base00"
      "base01"
      "base03"
      "base06"
      "base03"
      "base00"
      "base00"
      "base00"
      "base02"
      "base03"
      "base0D"
      "base0E"
      "base01"
      "base00"
      "base01"
      "base05"
      "base04"
    ];
    qtColorScheme = pkgs.writeText "base16-qtct-colors.conf" ''
      [ColorScheme]
      active_colors=${qtRow qtActive}
      disabled_colors=${qtRow qtDisabled}
      inactive_colors=${qtRow qtActive}
    '';
    qtctConf = ''
      [Appearance]
      style=Fusion
      custom_palette=true
      color_scheme_path=${qtColorScheme}
      icon_theme=${cfg.iconTheme.name}
      standard_dialogs=default

      [Fonts]
      general="${cfg.fonts.sansSerif.name},${toString cfg.fonts.sizes.applications}"
      fixed="${cfg.fonts.monospace.name},${toString cfg.fonts.sizes.terminal}"
    '';
  in
    lib.mkMerge [
      (lib.mkIf cfg.gtk.enable {
        rum.misc.gtk = {
          enable = true;
          packages = [pkgs.adw-gtk3 cfg.iconTheme.package];
          settings = {
            theme-name = gtkThemeName;
            icon-theme-name = cfg.iconTheme.name;
            cursor-theme-name = cfg.cursor.name;
            cursor-theme-size = cfg.cursor.size;
            font-name = appFont;
            application-prefer-dark-theme = cfg.polarity == "dark";
          };
          css.gtk3 = gtkCss;
          css.gtk4 = gtkCss;
        };
      })
      (lib.mkIf cfg.qt.enable {
        xdg.config.files = {
          "qt5ct/qt5ct.conf".text = qtctConf;
          "qt6ct/qt6ct.conf".text = qtctConf;
        };
      })
    ];
}
