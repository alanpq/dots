{
  flake.modules.nixos.theseus = {
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
