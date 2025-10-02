{pkgs, ...}: {
  nix = {
    distributedBuilds = true;
    settings.builders-use-substitutes = true;

    buildMachines = [
      {
        hostName = "warwick";
        sshUser = "remotebuild";
        sshKey = "/root/.ssh/remotebuild"; # ssh-keygen -f /root/.ssh/remotebuild
        inherit (pkgs.stdenv.hostPlatform) system;
        supportedFeatures = ["nixos-test" "big-parallel" "kvm"];
      }
    ];
  };
}
