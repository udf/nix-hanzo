{ config, lib, pkgs, ... }:
{
  services.smartd = {
    enable = true;
    notifications = {
      # test = true;
      mail = {
        enable = true;
        sender = "smartd on ${config.networking.hostName}";
      };
    };
    devices = [
      {
        device = "/dev/nvme0";
        options = lib.concatStringsSep " " [
          "-a"
          "-s (S/../../1/00|L/../(07|22)/./18)"
          "-W 0,0,80"
        ];
      }
      {
        device = "/dev/sda";
        options = "-d removable";
      }
      {
        device = "/dev/sdb";
        options = "-d removable";
      }
    ];
    defaults.monitored = lib.concatStringsSep " " [
      "-a"
      "-c i=${toString (2 * 60 * 60)}"
      "-s (S/../../1/00|L/../(07|22)/./18)"
      "-W 0,0,45"
    ];
  };
}
