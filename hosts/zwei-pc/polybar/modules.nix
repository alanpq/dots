{
  "module/window" = {
    type = "internal/xwindow";
    label.text = "%title%";
    label.maxlen = 100;
  };


  "module/cpu" = {
    type = "internal/cpu";
    interval = 2;
    format = "<label> <ramp-coreload>";
    label = "CPU";


    ramp.coreload-0.text = "%{T4}▁%{T-}";
    ramp.coreload-0.font = 5;
    ramp.coreload-0.foreground = "#aaff77";
    ramp.coreload-1.text = "%{T4}▂%{T-}";
    ramp.coreload-1.font = 5;
    ramp.coreload-1.foreground = "#A4FA48";
    ramp.coreload-2.text = "%{T4}▃%{T-}";
    ramp.coreload-2.font = 5;
    ramp.coreload-2.foreground = "#BDFB22";
    ramp.coreload-3.text = "%{T4}▄%{T-}";
    ramp.coreload-3.font = 5;
    ramp.coreload-3.foreground = "#FBE922";
    ramp.coreload-4.text = "%{T4}▅%{T-}";
    ramp.coreload-4.font = 5;
    ramp.coreload-4.foreground = "#fba922";
    ramp.coreload-5.text = "%{T4}▆%{T-}";
    ramp.coreload-5.font = 5;
    ramp.coreload-5.foreground = "#FB7922";
    ramp.coreload-6.text = "%{T4}▇%{T-}";
    ramp.coreload-6.font = 5;
    ramp.coreload-6.foreground = "#ff5555";
    ramp.coreload-7.text = "%{T4}█%{T-}";
    ramp.coreload-7.font = 5;
    ramp.coreload-7.foreground = "#FF3838";
  };


  "module/date" = {
    type = "internal/date";
    date.text = "%A, %d %B %Y (%d/%m/%y) %H:%M";
  };


  "module/workspaces" = {
    type = "internal/i3";
    pin-workspaces = true; # only show workspaces for that monitor
  };


  "module/memory" = {
    type = "internal/memory";
    interval = 3;
    format = "<label>";
    label = "RAM %gb_used%/%gb_total%";
  };


  "module/wired-network" = {
    type = "internal/network";
    interface = "enp0s31f6";
    interval = 10;
    label.connected = "%{T2}🖥️%{T-} %local_ip%";
    label.disconnected.foreground = "#66";
  };


  "module/wireless-network" = {
    type = "internal/network";
    interface = "wlp5s0";
    interval = 10;
    label.connected = "%{T2}📶%{T-} %local_ip%";
    label.disconnected.foreground = "#66";
  };


  "module/volume" = {
    type = "internal/alsa";
    master.mixer = "Master";
    #headphone-mixer = Headphone
    #headphone-id = 9


    format.volume = "<ramp-volume><label-volume>";
    label.muted.text = "%{T3}🔇%{T-} 00%";
    label.muted.foreground = "#aa";


    ramp.volume-0 = "%{T3}🔈%{T-} ";
    ramp.volume-1 = "%{T3}🔉%{T-} ";
    ramp.volume-2 = "%{T3}🔊%{T-} ";
  };


  "module/powermenu" = {
    type = "custom/menu";


    label-open = "Menu |";
    label-close = "Close ->";


    # menu-0-0.text = "Terminate WM ";
    # menu-0-0.foreground = "#fba922";
    # menu-0-0.exec = "bspc quit -1";
    # menu-0-1.text = "Reboot ";
    # menu-0-1.foreground = "#fba922";
    # menu-0-1.exec = "menu_open-1";
    # menu-0-2.text = "Power off ";
    # menu-0-2.foreground = "#fba922";
    # menu-0-2.exec = "menu_open-2";


    menu-0-0.text = "Cancel ";
    menu-0-0.foreground = "#fba922";
    menu-0-0.exec = "menu_open-0";
    menu-0-1.text = "Reboot ";
    menu-0-1.foreground = "#fba922";
    menu-0-1.exec = "reboot";


    menu-1-0.text = "Power off ";
    menu-1-0.foreground = "#fba922";
    menu-1-0.exec = "shutdown now";
    menu-1-1.text = "Cancel ";
    menu-1-1.foreground = "#fba922";
    menu-1-1.exec = "menu_open-0";
  };


  "module/clock" = {
    type = "internal/date";
    interval = 2;
    date = "%%{F#999}%Y-%m-%d%%{F-}  %%{F#fff}%H:%M%%{F-}";
  };
}
