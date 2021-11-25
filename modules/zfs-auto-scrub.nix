{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.zfs-auto-scrub;
in
{
  options.services.zfs-auto-scrub = mkOption {
    description = "Set of pools to scrub, and when to scrub them";
    type = types.attrsOf types.str;
    default = {};
  };

  config.systemd = mkMerge (mapAttrsToList (
    name: interval: {
      services."zfs-scrub-${name}" = {
        description = "ZFS scrub for pool ${name}";
        after = [ "zfs-import.target" ];
        serviceConfig = {
          Type = "oneshot";
        };
        script = "${config.boot.zfs.package}/bin/zpool scrub ${name}";
      };

      timers."zfs-scrub-${name}" = {
        wantedBy = [ "timers.target" ];
        after = [ "multi-user.target" ];
        timerConfig = {
          OnCalendar = interval;
          Persistent = "yes";
        };
      };
    }
  ) cfg);
}