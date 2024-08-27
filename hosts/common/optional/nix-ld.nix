{ pkgs, lib, config, inputs, ... }: let
  nix-ld-so = pkgs.runCommand "ld.so" {} ''
    ln -s "$(cat '${pkgs.stdenv.cc}/nix-support/dynamic-linker')" $out
  '';
in 
{
  programs.nix-ld.enable = true;
  environment.variables = {
    NIX_LD = lib.mkDefault (toString nix-ld-so);
  };
}
