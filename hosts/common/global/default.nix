# This file (and the global directory) holds config that i use on all hosts
{
  inputs,
  outputs,
  ...
}: {
  imports = [
    ./minimal.nix
    ./gamemode.nix
    ./optin-persistence.nix
    ./systemd-initrd.nix
  ];
}
