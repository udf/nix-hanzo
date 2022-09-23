{ config, lib, pkgs, ... }:
let
  makeScript = import ../helpers/make-script.nix { inherit lib pkgs; };
in
{
  systemd = {
    timers.flood-cleanup = {
      wantedBy = [ "timers.target" ];
      partOf = [ "flood-cleanup.service" ];
      timerConfig = {
        OnCalendar = "*-*-* 01:30:00";
        Persistent = true;
      };
    };
    services.flood-cleanup = {
      path = [
        (pkgs.python3.withPackages (ps: [
          ps.requests
        ]))
      ];
      serviceConfig = {
        Type = "oneshot";
        User = "flood-cleaner";
        Group = "flood-cleaner";
        WorkingDirectory = "/home/flood-cleaner";
        ExecStart = makeScript ../scripts/flood-cleanup.py;
      };
    };
  };

  users.extraUsers.flood-cleaner = {
    description = "Deletes excess torrents from Flood";
    createHome = true;
    isSystemUser = true;
    group = "flood-cleaner";
  };
  users.groups.flood-cleaner = { };
}
