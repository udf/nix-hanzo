{ config, lib, pkgs, ... }:
{
  services.syncplay = {
    enable = true;
    useACMEHost = "durga.withsam.org";
  };
  systemd.services.syncplay.environment = {
    SYNCPLAY_PASSWORD = "hentai";
  };
  networking.firewall.allowedTCPPorts = [ config.services.syncplay.port ];
}
