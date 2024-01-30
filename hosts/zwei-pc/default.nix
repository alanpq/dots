{ pkgs, inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.hardware.nixosModules.common-pc-ssd # fstrim is here
    ./hardware-configuration.nix
    ../common/global

    ../common/optional/ephemeral-btrfs.nix

    ../common/optional/pipewire.nix

    ../common/optional/libvirt.nix
    ../common/optional/tui-greetd.nix
    ../common/optional/systemd-boot.nix

    ../common/users/alan
  ];

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

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    # displayManager.gdm = {
    #   enable = true;
    #   wayland = true;
    # };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vaapiVdpau
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
      setLdLibraryPath = true;
    };
    nvidia.modesetting.enable = true;
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

  system.stateVersion = "22.11";
}
