{ pkgs, lib, config, ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  environment.persistence."/persist" = {
    directories = [
      "/var/lib/libvirt"
    ];
  };
}
