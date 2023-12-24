{ pkgs, ... }:
{
  systemd.user = {
    services.nextcloud-autosync = {
      Unit = {
        Description = "Auto sync Nextcloud";
        After = "network-online.target"; 
      };
      Service = {
        Type = "simple";
        ExecStart= "${pkgs.nextcloud-client}/bin/nextcloudcmd -h -n --path /Pictures /home/alan/Pictures https://nextcloud.alanp.me"; 
        TimeoutStopSec = "180";
        KillMode = "process";
        KillSignal = "SIGINT";
      };
      Install.WantedBy = ["multi-user.target"];
    };
    timers.nextcloud-autosync = {
      Unit.Description = "Automatic sync password with Nextcloud when booted up after 5 minutes then rerun every 60 minutes";
      Timer.OnBootSec = "5min";
      Timer.OnUnitActiveSec = "60min";
      Install.WantedBy = ["multi-user.target" "timers.target"];
    };
  };
}
