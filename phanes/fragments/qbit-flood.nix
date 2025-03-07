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

  environment.etc."qbit/on_done.sh".source = pkgs.writeScript "on_done.sh" ''
    #!${pkgs.bash}/bin/bash
    # on_done.sh "%F" "/path/to/dest/" {syncthing api key} {syncthing folder id}
    cp -al "$1" "$2"
    ${lib.getExe pkgs.curl} -X POST -H "X-API-Key:$3" "http://localhost:8384/rest/db/scan?folder=$4"
  '';

  networking.firewall = {
    allowedTCPPorts = [ 32431 ];
    allowedUDPPorts = [ 32431 ];
  };

  users.users.sam.extraGroups = [ "qbittorrent" ];

  systemd.services.qbittorrent.unitConfig.RequiresMountsFor = "/backup/qbit";
  systemd.services.flood.unitConfig.RequiresMountsFor = "/backup/qbit";
}