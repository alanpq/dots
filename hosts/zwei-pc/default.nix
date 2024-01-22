{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia
    inputs.hardware.nixosModules.common-pc-ssd # fstrim is here
    ./hardware-configuration.nix
    ../common/global

    ../common/optional/ephemeral-btrfs.nix

    ../common/optional/libvirt.nix
    ../common/optional/greetd.nix

    ../common/users/alan
  ];


  # Use the systemd-boot EFI boot loader.
  # boot.loader = {
  #   systemd-boot = {
  #     enable = true;
  #     consoleMode = "max";
  #   };
  #   efi.canTouchEfiVariables = true;
  # };


  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    binfmt.emulatedSystems = [ "aarch64-linux" "i686-linux" ];
  };

  networking = {
    hostName = "zwei-pc";
    useDHCP = true;
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    kdeconnect.enable = true;
  };


  hardware = {
    opengl.enable = true;
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

  fileSystems."/var/lib/libvirt" = {
    depends = [
      "/persist"
      "/"
    ];
    device = "/persist/var/lib/libvirt";
    fsType = "none";
    options = [ "bind" ];
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';
  # ============== END OF PERSISTENCE RELATED CONFIG ================

  system.stateVersion = "22.11";
}
