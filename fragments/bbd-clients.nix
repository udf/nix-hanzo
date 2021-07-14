{ config, lib, pkgs, ... }:
{
  systemd = {
    timers.bbd-clients = {
      wantedBy = [ "timers.target" ];
      partOf = [ "bbd-clients.service" ];
      timerConfig = {
        OnCalendar = "*-*-* 02:20:00 UTC"; # blaze it
        Persistent = true;
      };
    };
    services.bbd-clients = {
      path = [
        pkgs.nodejs
        pkgs.bash
        pkgs.diffutils
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "bbdc";
        WorkingDirectory = "/home/bbdc/bbdclients";
        ExecStart = "/home/bbdc/bbdclients/run.sh";
      };
    };
  };
  
  users.extraUsers.bbdc = {
    description = "Posts list of BBD clients to Telegram";
    home = "/home/bbdc";
    createHome = true;
    isSystemUser = true;
  };
}