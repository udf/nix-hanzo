{ config, lib, pkgs, ... }:
let
  zfs_auto_options = [
    "zfsutil"
    "x-systemd.automount"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
    "x-systemd.rw-only"
    "nofail"
    "noauto"
  ];
in
{
  boot.zfs.requestEncryptionCredentials = [ "backup/qbit" ];
  systemd.services.zfs-import-backup.serviceConfig.TimeoutStartSec = 10;

  fileSystems = {
    "/backup/qbit" = {
      device = "backup/qbit";
      fsType = "zfs";
      options = zfs_auto_options;
    };
    "/backup/music" = {
      device = "backup/music";
      fsType = "zfs";
      options = zfs_auto_options;
    };
    "/backup/soulseek-downloads" = {
      device = "backup/music/soulseek-downloads";
      fsType = "zfs";
      options = zfs_auto_options;
    };
  };

  services.smartd.devices = [
    {
      device = "/dev/disk/by-id/ata-WDC_WUH721818ALE6L4_3WJ9ZG4J";
      options = lib.concatStringsSep " " [
        "-a"
        "-c i=${toString (2 * 60 * 60)}"
        "-s (S/../../1/00|L/../(07|22)/./18)"
        "-W 0,0,45"
        "-d removable"
      ];
    }
  ];
}
