{ pkgs, lib, config, ... }:
{
  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
}
