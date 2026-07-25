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
      nvidia
      # bluetooth
    ];

    boot = {
      kernelPackages = pkgs.linuxKernel.packages.linux_zen;
      binfmt.emulatedSystems = ["aarch64-linux" "i686-linux"];
      supportedFilesystems = ["ntfs"];
    };

    networking = {
      hostName = "${hostname}";
      useDHCP = lib.mkDefault true;
      dhcpcd.IPv6rs = false;

      extraHosts = ''
        ${builtins.concatStringsSep "." ["49" "12" "127" "28"]} uptrace.local
      '';
    };

    powerManagement.cpuFreqGovernor = "performance";

    system.stateVersion = lib.mkForce "22.11";

    hardware = {
      graphics.enable = true;
      graphics.enable32Bit = true;
      opentabletdriver.enable = true;
    };

    services.xserver = {
      enable = true;
      # displayManager.gdm = {
      #   enable = true;
      #   wayland = true;
      # };
    };

    environment.sessionVariables = {
      # LIBVA_DRIVER_NAME = "nvidia";
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # __GL_VRR_ALLOWED = "1";
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
