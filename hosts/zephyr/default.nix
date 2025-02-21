{
  modulesPath,
  lib,
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.alanp-web.nixosModules.default
    inputs.heardle.nixosModules.default
    ./disk-config.nix
    ./hardware-configuration.nix
  ];
  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };
  };
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.nss.tools # needed for caddy self signed certs?
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKKUWJ2oqT2pcU1LR8iOG03FXh8rBsUg8yNfEi13yofq alan@gamer-think"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDV4FQ1An54LmVlMoNbAEKaOouVd2Jgd31lp0fiod5R56noBA8v8kQoFZALtmqMB1iLvEtReeclmSxfuwJMpqf3xZQQ/5dsGaFHsPFSA0AdlJmEnSDdzWXHDzFvGRWLhULggQAjN+Gw1SMe4nzrcxfxk5gbxtRXz4oI0lTDCcL743qWh1LxUV1gJgcpPD/mLwx51GAp4KeDIuLcTlW9D7RzVc1SGeI13VOKjHkY7AiiBsY+3oEJpmvnAop0vMdLdoIddIWYD1uVW9U9VN/rIexQyrC0phJqZCQjdYaFLgTfSor5THdEK0TMlNOd6NZ/zm66fMpTKav94XDPonNb+LGwISgjh2Stpworqq9TpslotVmKAKg33GnlTOhGMy63Fx/+xu7FCl8nzEMG6QtAsTk6KnoQzK0gYckyreRDD/+A6tH8CQ5C5h/gt3w0VX0dBVOprO15w6QTrK4xoPqyLLXoJBtvGEnpRmINGkZXaaAlwRTN6PsLqzOxefBW9shDFm0= alan@zwei-pc"
  ];

  services.alanp-web = {
    enable = true;
    listenHost = "127.0.1.1";
    port = 8080;
  };

  services.heardle = {
    enable = true;
    listenHost = "127.0.1.2";
    databaseUrl = "postgres://heardle/heardle?host=/run/postgresql/";
    port = 8081;
  };

  services.postgresql.enable = true;
  services.postgresql.ensureDatabases = ["heardle"];
  services.postgresql.ensureUsers = [
    {
      name = "heardle";
      ensureDBOwnership = true;
    }
  ];
  services.postgresql.identMap = lib.mkForce ''
    heardle-users heardle heardle
    heardle-users root heardle
  '';

  services.postgresql.authentication = ''
    local heardle all peer map=heardle-users
  '';

  services.caddy = {
    enable = true;
    # cloudflare covers us ssl-wise, we just need self signed certs
    globalConfig = ''
      local_certs
    '';
    virtualHosts."alanp.me".extraConfig = ''
      reverse_proxy http://${config.services.alanp-web.listenHost}:${toString config.services.alanp-web.port}
    '';
    virtualHosts."heardle.alanp.me".extraConfig = ''
      reverse_proxy http://${config.services.heardle.listenHost}:${toString config.services.heardle.port}
    '';
  };
  networking.firewall.allowedTCPPorts = [80 443];

  system.stateVersion = "24.05";
}
