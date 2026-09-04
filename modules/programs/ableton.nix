{inputs, ...}: {
  flake-file.inputs = {
    ableton = {
      url = "github:shibco/ableton-linux";
    };
  };
  flake.modules.hjem.ableton = {pkgs, ...}: {
    packages = [inputs.ableton.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };
}
