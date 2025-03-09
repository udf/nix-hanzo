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
}
