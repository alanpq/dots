{
  flake.modules.hjem.niri = {lib, ...}: {
    rum.desktops.niri = let
      place = let
        defaultMonitor = {
          position = {
            x = 0;
            y = 0;
          };
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
            x = other.position.x - self.width;
            inherit (other.position) y;
          }
        );
        rightOf = mkPlacer (
          self: other: {
            x = other.position.x + self.width;
            inherit (other.position) y;
          }
        );
      };

      outputs = lib.fix (self: {
        "DP-1" = {
          width = 1920;
          height = 1080;
          rate = "144.001";
        };
        "DVI-D-1" =
          place.rightOf "DP-1" {
            width = 1920;
            height = 1080;
            # rate = "144.001";
            rate = "60";

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
            }
          ''
        )
        outputs);
    };
  };
}
