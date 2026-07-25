{inputs, ...}: {
  flake.modules.nixos.chudpad = {
    imports = [
      inputs.hardware.nixosModules.common-cpu-intel
      inputs.hardware.nixosModules.common-gpu-intel
      inputs.hardware.nixosModules.lenovo-thinkpad-t14
    ];
    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = true;

    boot = {
      kernelModules = [];
      extraModulePackages = [];
      initrd = {
        availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci"];
        kernelModules = ["dm-snapshot"];
      };
    };
  };
}
