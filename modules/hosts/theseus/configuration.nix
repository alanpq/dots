{
  inputs,
  lib,
  ...
}: let
  hostname = "theseus";
in {
  flake.modules.nixos.${hostname} = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      system-desktop
      grub
      # bluetooth
    ];

    environment.systemPackages = [];

    networking = {
      hostName = "${hostname}";
      useDHCP = lib.mkDefault true;
      dhcpcd.IPv6rs = false;
    };

    system.stateVersion = lib.mkForce "22.11";
  };
}
