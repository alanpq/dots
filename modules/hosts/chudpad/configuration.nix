{
  inputs,
  lib,
  ...
}: {
  flake.modules.nixos.chudpad = {
    imports = with inputs.self.modules.nixos; [
      system-laptop
      systemd-boot
      # bluetooth
    ];

    networking = {
      hostName = "chudpad";
      useDHCP = lib.mkDefault true;
      dhcpcd.IPv6rs = false;
    };

    system.stateVersion = lib.mkForce "24.05";
  };
}
