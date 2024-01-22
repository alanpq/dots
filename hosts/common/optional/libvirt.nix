{ pkgs, lib, config, ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
}
