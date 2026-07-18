{
  inputs,
  lib,
  ...
}: {
  flake.modules.nixos.chudpad = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      system-laptop
      systemd-boot
      # bluetooth
    ];

    environment.systemPackages = [pkgs.wpa_supplicant_gui pkgs.steam];

    networking = {
      hostName = "chudpad";
      useDHCP = lib.mkDefault true;
      dhcpcd.IPv6rs = false;
    };

    system.stateVersion = lib.mkForce "24.05";
  };
}
