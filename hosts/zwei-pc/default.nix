{ pkgs, inputs, config, ... }: {
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    # inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
    inputs.hardware.nixosModules.common-pc-ssd # fstrim is here
    ./hardware-configuration.nix
    ../common/global

    ../common/optional/ephemeral-btrfs.nix

    ../common/optional/pipewire.nix

    ../common/optional/docker.nix
    ../common/optional/libvirt.nix
    ../common/optional/tui-greetd.nix
    ../common/optional/grub.nix
    ../common/optional/fonts

    ../common/users/alan
  ];

  services.ollama = {
  #package = pkgs.unstable.ollama; # Uncomment if you want to use the unstable channel, see https://fictionbecomesfact.com/nixos-unstable-channel
  enable = true;
  acceleration = "cuda"; # Or "rocm"
  #environmentVariables = { # I haven't been able to get this to work myself yet, but I'm sharing it for the sake of completeness
    # HOME = "/home/ollama";
    # OLLAMA_MODELS = "/home/ollama/models";
    # OLLAMA_HOST = "0.0.0.0:11434"; # Make Ollama accesible outside of localhost
    # OLLAMA_ORIGINS = "http://localhost:8080,http://192.168.0.10:*"; # Allow access, otherwise Ollama returns 403 forbidden due to CORS
  #};
};

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_zen;
    binfmt.emulatedSystems = [ "aarch64-linux" "i686-linux" ];
    supportedFilesystems = [ "ntfs" ];
    kernelParams = [
      "nvidia_drm.fbdev=1"
    ];
  };
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
  security.polkit.enable = true;


  # set $FS_UUID to the UUID of the EFI partition
  boot.loader.grub.extraEntries = ''
    menuentry "Windows" {
      insmod part_gpt
      insmod fat
      insmod search_fs_uuid
      insmod chain
      search --fs-uuid --set=root 07d99471-57c7-47cb-afc8-103536b2d39d
      chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';

  powerManagement.cpuFreqGovernor = "performance";

  networking = {
    hostName = "zwei-pc";
    useDHCP = true;
  };

  programs = {
    adb.enable = true;
    dconf.enable = true;
    kdeconnect.enable = true;
  };
services.flatpak.enable = true;
xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.inputs.hyprland.xdg-desktop-portal-hyprland ];
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
    GDK_BACKEND = "wayland,x11";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
    _JAVA_AWT_VM_NONREPARENTING = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORM = "wayland";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __NV_PRIME_RENDER_OFFLOAD = "1";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
    PROTON_ENABLE_NGX_UPDATER = "1";
    NVD_BACKEND = "direct";
    __GL_VRR_ALLOWED = "1";
    WLR_DRM_NO_ATOMIC = "1";
    WLR_USE_LIBINPUT = "1";
    # XWAYLAND_NO_GLAMOR = "1"; # with this you'll need to use gamescope for gaming
    __GL_MaxFramesAllowed = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    XDG_SESSION_TYPE = "wayland";
    VDPAU_DRIVER = "va_gl";
    NIXOS_OZONE_WL = "1";
  };

  # TODO: put these aliases with the associated packages (exa, bat, etc)
  environment.shellAliases = {
    ls = "exa";
    ll = "exa -l";
    la = "exa -la";
    tree = "exa -T";

    ip = "ip -color";

    cat = "bat --paging never";
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
    nvidia = {
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
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

  system.stateVersion = "22.11";
}
