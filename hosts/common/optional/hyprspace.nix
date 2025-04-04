{
  pkgs,
  inputs,
  config,
  ...
}: {
  services.hyprspace = {
    enable = true;

    privateKeyFile = config.sops.secrets.hyprspace-key.path;

    settings = {
      peers = [
        # {
        #   "name" = "zwei-pc";
        #   "id" = "12D3KooWNwEhBi6URePvDzM8Ws5Bty2e1r3S5j4tFc4uAf1vc7cf";
        # }
      ];
    };
  };

  sops.secrets.hyprspace-key = {
    sopsFile = ../secrets.yaml;
  };

  environment.systemPackages = [config.services.hyprspace.package];
}
