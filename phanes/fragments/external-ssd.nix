{ config, lib, pkgs, ... }:
{
  fileSystems."/external" = {
    device = "/dev/disk/by-uuid/71E59486179CC7B0";
    fsType = "ntfs3";
    options = [
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "x-systemd.rw-only"
      "nofail"
      "x-systemd.idle-timeout=20s"
      "uid=syncthing"
      "gid=syncthing"
      "umask=0077"
      "discard"
    ];
  };
}
