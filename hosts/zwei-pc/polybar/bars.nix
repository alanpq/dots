{ monitors }:
let
  bars = builtins.concatMap
    (
      mon: [{
        name = "bar/top-${mon}";
        value = {
          monitor = mon;

          bottom = false;
          font-0 = "Iosevka:size=10"; # text
          font-1 =
            "Font Awesome 6 Free:size=10:style=Solid"; # globe, antenna signal
          font-2 =
            "Noto Sans Symbols 2:size=10"; # no sound, volume 1, volume 2, volume 3, disk
          font-3 = "Noto Sans Mono:size=10"; # bars
          modules.left = "window";
          modules.right =
            "cpu memory volume wired-network wireless-network date";


          module.margin = 1;
          height = 19;
          padding = 2;


          background = "#00949494"; # #94949400
          foreground = "#FF000000";
          border.size = "2pt";


          line.color = "\${bar/top.background}";
          line.size = 19;


          separator = "|";


          locale = "en_US.UTF-8";
        };
      }

        {
          name = "bar/bottom-${mon}";
          value = {
            monitor = mon;
            bottom = true;
            font-0 = "Iosevka:size=11"; # text
            font-1 =
              "Font Awesome 6 Free:size=9:style=Solid"; # globe, antenna signal
            font-2 =
              "Noto Sans Symbols 2:size=9"; # no sound, volume 1, volume 2, volume 3, disk
            font-3 = "Noto Sans Mono:size=9"; # bars
            modules.left = "workspaces";


            module.margin = 1;
            height = 18;


            background = "#000000ff";
            foreground = "#ccffffff";
            border.size = "2pt";


            line.color = "\${bar/top.background}";
            line.size = 18;


            separator = "|";


            locale = "en_US.UTF-8";
          };
        }]
    )
    monitors;
in
builtins.listToAttrs bars
