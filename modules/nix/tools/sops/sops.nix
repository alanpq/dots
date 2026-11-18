{inputs, ...}: {
  # Per-host secrets: each host decrypts modules/hosts/<hostname>/secrets.yaml
  # with its own ssh ed25519 host key (converted to age). Recipients live in
  # /.sops.yaml; create/edit a host's file with `sops modules/hosts/<host>/secrets.yaml`.
  flake.modules.nixos.secrets = {
    config,
    lib,
    ...
  }: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops = {
      defaultSopsFile = lib.mkDefault ../../../hosts/${config.networking.hostName}/secrets.yaml;
      age.sshKeyPaths =
        map (k: k.path)
        (lib.filter (k: k.type == "ed25519") config.services.openssh.hostKeys);
      # hosts only hold age identities; don't import RSA host keys into a gpg keyring
      gnupg.sshKeyPaths = [];
    };
  };
}
