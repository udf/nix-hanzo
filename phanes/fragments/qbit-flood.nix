{ config, lib, pkgs, ... }:
{
  services.qbittorrent = {
    enable = true;
    port = 8081;
    openFirewall = true;
    maxMemory = "4G";
    maxSwap = "2G";
  };

  services.flood = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
    port = 3000;
  };

  environment.etc."qbit/on_done.sh".source = pkgs.writeScript "on_done.sh" ''
    #!${pkgs.bash}/bin/bash
    # on_done.sh "%N" "%F" "/path/to/dest/" {syncthing api key} {syncthing folder id}
    echo "<4>Download completed: $1"
    cp -al "$2" "$3"
    ${lib.getExe pkgs.curl} -s -X POST -H "X-API-Key:$4" "http://localhost:8384/rest/db/scan?folder=$5"
  '';

  networking.firewall = {
    allowedTCPPorts = [ 32431 ];
    allowedUDPPorts = [ 32431 ];
  };

  custom.ipset-block.exceptPorts = [ 32431 ];

  users.users.sam.extraGroups = [ "qbittorrent" ];

  systemd.services.qbittorrent.unitConfig.RequiresMountsFor = "/backup/qbit";
  systemd.services.flood.unitConfig.RequiresMountsFor = "/backup/qbit";
}