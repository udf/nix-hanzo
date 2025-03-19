{ config, lib, pkgs, ... }:
{
  services.smartd = {
    enable = true;
    autodetect = false;
    notifications = {
      # test = true;
      mail = {
        enable = true;
        sender = "smartd on ${config.networking.hostName}";
      };
    };
    devices = [
      {
        device = "/dev/disk/by-id/nvme-PM981_NVMe_Samsung_512GB__S3ZHNX0M314568";
        options = lib.concatStringsSep " " [
          "-a"
          "-s (S/../../1/00|L/../(07|22)/./18)"
          "-W 0,0,80"
        ];
      }
    ];
  };
}
