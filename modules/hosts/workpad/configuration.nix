{
  inputs,
  lib,
  ...
}: let
  hostname = "workpad";
in {
  flake.modules.nixos.${hostname} = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      system-laptop
      systemd-boot
      wireless
      # bluetooth
    ];

    # keep timezone imperative for travel
    # TODO: maybe make all laptop timezones imperative
    time.timeZone = lib.mkForce null;

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

    nixpkgs.overlays = [
      (
        final: prev: {
          intel-ocl = prev.intel-ocl.overrideAttrs (oldAttrs: {
            # Update version to match the new release
            version = "5.0-63503"; # Same version, but you might want to change if different

            src = prev.fetchzip {
              # New URL from GitHub releases
              urls = [
                "https://github.com/gnull/intel-ocl/releases/download/5.0-63503/SRB5.0_linux64.zip"
              ];
              # IMPORTANT: Replace with the actual SHA256 after downloading
              sha256 = "sha256-4qaX7wTqxKSrRWeQv1Zrs6eTT0fKJ6g9QBFocugwd2E=";
              stripRoot = false;
            };
          });
        }
      )
    ];
  };
}
