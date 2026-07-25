{
  inputs,
  lib,
  ...
}: let
  hostname = "chudpad";
in {
  flake.modules.nixos.${hostname} = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      system-laptop
      systemd-boot
      # bluetooth
    ];

    services.tailscale.enable = true;

    environment.systemPackages = [pkgs.wpa_supplicant_gui];

    hardware = {
      graphics = {
        enable = true;
      };
    };

    networking = {
      hostName = "${hostname}";
      useDHCP = lib.mkDefault true;
      dhcpcd.IPv6rs = false;
    };

    system.stateVersion = lib.mkForce "24.05";
  };
}
