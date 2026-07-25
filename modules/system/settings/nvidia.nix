{
  flake.modules.nixos.nvidia = {
    pkgs,
    config,
    lib,
    ...
  }: {
    boot.kernelParams = [
      "nvidia_drm.fbdev=1"
    ];

    hardware = {
      graphics = {
        extraPackages = with pkgs; [
          libva-vdpau-driver
          libvdpau-va-gl
        ];
        extraPackages32 =
          lib.mkIf config.hardware.graphics.enable32Bit
          [pkgs.pkgsi686Linux.libva];
      };
      nvidia = {
        open = false;
        package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
        modesetting.enable = true;
      };
    };

    services.xserver.videoDrivers = ["nvidia"];
  };
}
