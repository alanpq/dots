{
  flake.modules.nixos.fingerprint = {pkgs, ...}: {
    services.fprintd = {
      enable = true;
      tod = {
        enable = true;

        driver = pkgs.libfprint-2-tod1-goodix; # Goodix driver module
        # driver = pkgs.libfprint-2-tod1-elan; # Elan(04f3:0c4b) driver
        # driver = pkgs.libfprint-2-tod1-vfs0090; # (Marked as broken as of 2025/04/23!) driver for 2016 ThinkPads
        # driver = pkgs.libfprint-2-tod1-goodix-550a; # Goodix 550a driver (from Lenovo)
      };
    };
  };
}
