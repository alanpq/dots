{inputs, ...}: {
  flake-file.inputs = {
    biri.url = "github:barrulus/biri";
  };
  flake.modules.nixos.niri = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      awww
    ];
    environment.systemPackages = with pkgs; [
      wl-clipboard
      wtype
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xwayland-satellite

      grim
      slurp
      swappy
      # wf-recorder
      brightnessctl

      gnome-themes-extra
    ];

    programs.niri = {
      enable = true;
      package = inputs.biri.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;

    xdg.portal.config = {
      common = {
        default = [
          "gtk"
          "gnome"
        ];
      };
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
  flake.modules.hjem.niri = {
    rum.desktops.niri = {
      enable = true;
      config =
        builtins.readFile ./config.kdl
        + ''

        '';
    };
  };
}
