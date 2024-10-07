{ lib, pkgs, config, ... }: let 
  # window classes that should be minimised instead of killed
  minimiseClasses = [
    "Steam"
    # "org.keepassxc.KeePassXC"
  ];

  killactive = pkgs.writeShellApplication {
    name = "killactive";
    runtimeInputs = with pkgs; [xdotool config.wayland.windowManager.hyprland.package ];
    text = ''
      declare -a raw=(${lib.concatStringsSep " " (lib.map (x: "\"${x}\"" ) minimiseClasses)})
      declare -A classes # required: declare explicit associative array
      for key in "''${!raw[@]}"; do classes[''${raw[$key]}]="$key"; done  # see below

      class="$(hyprctl activewindow -j | jq -r ".class")"
      echo "$class"
      if [ ''${classes[$class]+_} ]; then
        xdotool getactivewindow windowunmap
      else
        hyprctl dispatch killactive ""
      fi
    '';
  } + "/bin/killactive";
in {
  wayland.windowManager.hyprland.settings = {
    bindm = [
      "SUPER,mouse:272,movewindow"
      "SUPER,mouse:273,resizewindow"
    ];

    bind = let
      workspaces = [
        "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
        "F1" "F2" "F3" "F4" "F5" "F6" "F7" "F8" "F9" "F10" "F11" "F12"
      ];
      # Map keys (arrows and hjkl) to hyprland directions (l, r, u, d)
      directions = rec {
        left = "l"; right = "r"; up = "u"; down = "d";
        h = left; l = right; k = up; j = down;
      };
    in [
      "SUPER,q,exec,${killactive}"
      "SUPERSHIFT,e,exit"

      "SUPERSHIFT,s,pin,active"

      "SUPER,s,togglesplit"
      "SUPER,f,fullscreen,1"
      "SUPERSHIFT,f,fullscreen,0"
      "SUPERSHIFT,space,togglefloating"

      "SUPER,minus,splitratio,-0.25"
      "SUPERCONTROL,minus,splitratio,-0.1"
      "SUPERSHIFT,minus,splitratio,-0.3333333"

      "SUPER,equal,splitratio,0.25"
      "SUPERCONTROL,equal,splitratio,0.1"
      "SUPERSHIFT,equal,splitratio,0.3333333"

      "SUPER,g,togglegroup"
      "SUPER,t,lockactivegroup,toggle"
      "SUPER,apostrophe,changegroupactive,f"
      "SUPERSHIFT,apostrophe,changegroupactive,b"

      "SUPER,u,togglespecialworkspace"
      "SUPERSHIFT,u,movetoworkspacesilent,special"
    ] ++
    # Change workspace
    (map (n:
      "SUPER,${n},workspace,name:${n}"
    ) workspaces) ++
    # Move window to workspace
    (map (n:
      "SUPERSHIFT,${n},movetoworkspacesilent,name:${n}"
    ) workspaces) ++
    # Move focus
    (lib.mapAttrsToList (key: direction:
      "SUPER,${key},movefocus,${direction}"
    ) directions) ++
    # Swap windows
    (lib.mapAttrsToList (key: direction:
      "SUPERSHIFT,${key},swapwindow,${direction}"
    ) directions) ++
    # Move windows
    (lib.mapAttrsToList (key: direction:
      "SUPERCONTROL,${key},movewindoworgroup,${direction}"
    ) directions) ++
    # Move monitor focus
    (lib.mapAttrsToList (key: direction:
      "SUPERALT,${key},focusmonitor,${direction}"
    ) directions) ++
    # Move workspace to other monitor
    (lib.mapAttrsToList (key: direction:
      "SUPERALTSHIFT,${key},movecurrentworkspacetomonitor,${direction}"
    ) directions);
  };
}
