{
  flake.modules.hjem.easyeffects = {pkgs, ...}: {
    systemd.services.easyeffects = {
      description = "EasyEffects";
      after = ["pipewire.service"];
      requires = ["pipewire.service"];

      serviceConfig = {
        ExecStart = "${pkgs.easyeffects}/bin/easyeffects --service-mode --hide-window";
        ExecStop = "${pkgs.easyeffects}/bin/easyeffects --quit";
        Restart = "on-failure";
      };

      wantedBy = ["default.target"];
    };
  };
}
