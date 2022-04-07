{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.services.backup-root;
in
{
  options.services.backup-root = {
    excludePaths = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of paths to exclude from root backup";
    };
  };

  config = {
    systemd.services.backup-root =
      let
        snapshotServices = (map
          (n: "zfs-snapshot-${n}.service")
          (builtins.filter (n: config.services.zfs.autoSnapshot."${n}" > 0) [ "hourly" "daily" "weekly" "monthly" ])
        );
        excludePaths = concatStringsSep ","
          (
            [ "/dev" "/proc" "/sys" "/tmp" "/run" "/lost+found" "/nix" "/var/log/lastlog" ]
            ++ cfg.excludePaths
          );
      in
      {
        description = "Backup root filesystem to the snapshot dataset";
        requiredBy = snapshotServices;
        before = snapshotServices;
        restartIfChanged = false;
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
        script = ''
          ${pkgs.rsync}/bin/rsync \
            -aAXHxx \
            --delete \
            --exclude={${excludePaths}} \
            / /backups/snapshots/root/ || ret=$?
          # ignore vanished file error
          if [[ $ret == 24 ]]; then
            ret=0
          fi
          exit $ret
        '';
      };
  };
}
