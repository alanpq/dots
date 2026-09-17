{
  flake.modules.hjem.niri = {lib, ...}: {
    rum.desktops.niri = let
      realWidth = monitor: (
        if (builtins.elem (monitor.transform or "n") ["90" "270"])
        then monitor.height
        else monitor.width
      );
      realHeight = monitor: (
        if (builtins.elem (monitor.transform or "n") ["90" "270"])
        then monitor.width
        else monitor.height
      );
      place = let
        defaultMonitor = {
          position = {
            x = 0;
            y = 0;
          };
          transform = "normal";
          rate = 60;
        };
        mkPlacer = f: output: monitor: self:
          monitor
          // {
            position =
              f (defaultMonitor
                // self.${
                  output
                })
              (
                defaultMonitor // monitor
              );
          };
      in {
        leftOf = mkPlacer (
          self: other: {
            x = other.position.x - realWidth self;
            y = other.position.y + self.position.y;
          }
        );
        rightOf = mkPlacer (
          self: other: {
            x = other.position.x + realWidth self;
            y = other.position.y + self.position.y;
          }
        );
      };

      outputs = lib.fix (self: {
        "DP-4" = {
          width = 1920;
          height = 1080;
          rate = "144.001";
          transform = "90";
        };
        "DVI-D-1" =
          place.rightOf "DP-4" {
            width = 1920;
            height = 1080;
            rate = "144.001";
            position = {
              x = 0;
              y = 520;
            };
            # rate = "60";

            primary = true;
          }
          self;
      });
    in {
      config = lib.strings.concatStringsSep "\n" (lib.mapAttrsToList (
          output: cfg: let
            pos =
              cfg.position or {
                x = 0;
                y = 0;
              };
          in ''
            output "${output}" {
                mode "${toString cfg.width}x${toString cfg.height}@${(cfg.rate or "60")}"
                position x=${toString pos.x} y=${toString pos.y}
                transform "${cfg.transform or "normal"}"
            }
          ''
        )
        outputs);
    };
  };
}
