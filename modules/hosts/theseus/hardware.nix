{inputs, ...}: {
  flake.modules.nixos.theseus = {
    imports = [
      inputs.hardware.nixosModules.common-cpu-amd
      inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
      inputs.hardware.nixosModules.common-pc-ssd
    ];

    nixpkgs.hostPlatform = "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = true;

    boot = {
      kernelModules = [];
      extraModulePackages = [];
      initrd = {
        availableKernelModules = ["xhci_pci" "nvme" "ahci" "usb_storage" "sd_mod" "usbhid"];
        kernelModules = ["kvm-amd"];
      };
    };
  };
}
