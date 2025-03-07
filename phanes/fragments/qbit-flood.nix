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
    host = "0.0.0.0";
    port = 3000;
  };

  services.watcher-bot.plugins = [ "flood" ];

  networking.firewall = {
    allowedTCPPorts = [ 32431 ];
    allowedUDPPorts = [ 32431 ];
  };

  users.users.sam.extraGroups = [ "qbittorrent" ];

  systemd.services.qbittorrent.unitConfig.RequiresMountsFor = "/backup/qbit";
  systemd.services.flood.unitConfig.RequiresMountsFor = "/backup/qbit";
}