{ config, lib, pkgs, ... }:
{
  fileSystems."/external" = {
    device = "/dev/disk/by-uuid/2B0AACD0029C68C2";
    fsType = "ntfs3";
    options = [
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "x-systemd.rw-only"
      "nofail"
      "uid=syncthing"
      "gid=syncthing"
      "umask=0077"
      "discard"
    ];
  };

  services.smartd.devices = [
    {
      device = "/dev/disk/by-id/ata-ST1000LM048-2E7172_WL1NA6XZ";
      options = lib.concatStringsSep " " [
        "-a"
        "-s (S/../../1/00|L/../(07|22)/./18)"
        "-W 0,0,65"
        "-d removable"
      ];
    }
  ];
}
