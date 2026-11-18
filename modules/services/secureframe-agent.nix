{inputs, ...}: {
  flake-file.inputs = {
    secureframe-agent.url = "github:alanpq/secframe";
  };
  flake.modules.nixos.secureframe-agent = {config, ...}: {
    imports = [inputs.secureframe-agent.nixosModules.default];
    services.secureframe-agent = {
      enable = true;
      hostIdentifier = "25873cac-51b2-4434-8814-1428006e76ed:822b8d3c-c87c-4794-ba57-ff7fcf54355e:0bf3e24e-c064-4855-8adb-f7942b0ae77a";
      enrollSecretFile = config.sops.secrets.secureframe-agent-enroll-secret.path;

      desktop.enable = true;
    };
    sops.secrets.secureframe-agent-enroll-secret = {};

    environment.systemPackages = [config.services.secureframe-agent.desktop.package];
  };
}
