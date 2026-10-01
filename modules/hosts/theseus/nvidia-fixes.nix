{
  flake.modules.nixos.theseus = {
    programs.firefox.preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.force-enabled" = true;
    };
    environment.sessionVariables = {
      # nvidia-vaapi-driver: use the NVDEC "direct" backend instead of the EGL
      # one so the browsers' decode process can init VA-API without needing a
      # GBM/EGL context handed to it.
      NVD_BACKEND = "direct";
      # nvidia-vaapi-driver loads libcuda in Firefox's RDD (media) process, which
      # the RDD sandbox otherwise blocks -> decode silently fails at runtime.
      MOZ_DISABLE_RDD_SANDBOX = "1";
      # LIBVA_DRIVER_NAME is intentionally unset: VA-API auto-detects "nvidia"
      # for the nvidia render node, and forcing it globally would also (wrongly)
      # redirect the AMD iGPU's render node to the nvidia driver.
    };
  };
}
