{ config, lib, pkgs, ... }:
{
  boot.zfs.requestEncryptionCredentials = [ "backup/qbit" ];

  fileSystems."/backup/qbit" = {
    device = "backup/qbit";
    fsType = "zfs";
    options = [
      "zfsutil"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "x-systemd.rw-only"
      "nofail"
      "noauto"
    ];
  };
}
