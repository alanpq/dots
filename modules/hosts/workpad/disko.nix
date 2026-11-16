{inputs, ...}: {
  flake.modules.nixos.workpad = {
	imports = [inputs.disko.nixosModules.disko];
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
            swap = {
              size = "65G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true; # allow TRIM requests to the device
                  # keyFile = "/dev/disk/by-partlabel/LUKSKEY";
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"]; # Override existing partition
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                    };
                    "/home" = {
                      mountOptions = ["compress=zstd" "noatime"];
                      mountpoint = "/home";
                    };
                    "/nix" = {
                      mountOptions = ["compress=zstd" "noatime"];
                      mountpoint = "/nix";
                    };
                    # persisted + usually backed up
                    "/persist" = {
                      mountOptions = ["compress=zstd" "noatime"];
                      mountpoint = "/persist";
                    };
                    # like /persist, but we don't care about backups
                    "/cache" = {
                    };
                    "/cache/logs" = {
                      mountOptions = ["compress=zstd" "noatime"];
                      mountpoint = "/var/log";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
};
}
