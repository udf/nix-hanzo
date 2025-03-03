{ config, lib, pkgs, ... }:
{
  services.qbittorrent = {
    enable = true;
    port = 8081;
    openFirewall = true;
    maxMemory = "4G";
  };

  services.flood = {
    enable = true;
    openFirewall = true;
    host = "192.168.0.5";
    port = 3000;
  };

  users.users.sam.extraGroups = [ "qbittorrent" ];

  systemd.services.qbittorrent.unitConfig.RequiresMountsFor = "/backup/qbit";
  systemd.services.flood.unitConfig.RequiresMountsFor = "/backup/qbit";
}