{
  inputs,
  lib,
  ...
}: let
  hostname = "theseus";
in {
  flake.modules.nixos.${hostname} = {
    pkgs,
    config,
    ...
  }: {
    imports = with inputs.self.modules.nixos; [
      system-desktop
      grub
      # bluetooth
    ];

    services.tailscale.enable = true;

    environment.systemPackages = [];

    networking = {
      hostName = "${hostname}";
      useDHCP = lib.mkDefault true;
      dhcpcd.IPv6rs = false;

      extraHosts = ''
        ${builtins.concatStringsSep "." ["49" "12" "127" "28"]} uptrace.local
      '';
    };

    system.stateVersion = lib.mkForce "22.11";

    boot.kernelPackages = pkgs.linuxPackages;
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          libva-vdpau-driver
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [libva];
      };
      nvidia = {
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
        modesetting.enable = true;
      };
      opentabletdriver.enable = true;
    };

    # TODO: modularise this
    # ============== PERSISTENCE RELATED CONFIG ================
    environment.etc = {
      nixos.source = "/persist/etc/nixos";
      #passwd.source = "/persist/etc/passwd";
      #shadow.source = "/persist/etc/shadow";

      #group.source = "/persist/etc/group";
      subgid.source = "/persist/etc/subgid";
      subuid.source = "/persist/etc/subuid";

      adjtime.source = "/persist/etc/adjtime";
      NIXOS.source = "/persist/etc/NIXOS";
      machine-id.source = "/persist/etc/machine-id";

      "NetworkManager/system-connections".source = "/persist/etc/NetworkManager/system-connections";
    };
    systemd.tmpfiles.rules = [
      "L /var/lib/NetworkManager/secret_key - - - - /persist/var/lib/NetworkManager/secret_key"
      "L /var/lib/NetworkManager/seen-bssids - - - - /persist/var/lib/NetworkManager/seen-bssids"
      "L /var/lib/NetworkManager/timestamps - - - - /persist/var/lib/NetworkManager/timestamps"

      # "L /var/lib/libvirt - - - - /persist/var/lib/libvirt"
    ];

    security.sudo.extraConfig = ''
      # rollback results in sudo lectures after each reboot
      Defaults lecture = never
    '';
    # ============== END OF PERSISTENCE RELATED CONFIG ================
  };
}
