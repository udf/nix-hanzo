{ config, lib, pkgs, ... }:
with lib;
let
  ipPrefix = "192.168.1";
  containerIP = "${ipPrefix}.2";
  webUIPort = 8080;
  floodUIPort = 3000;
in
{
  imports = [
    ../constants/vpn.nix
    ../modules/vpn-containers.nix
  ];

  services.nginxProxy.paths = {
    "flood" = {
      port = floodUIPort;
      host = containerIP;
      authMessage = "What say you in your defense?";
      rewrite = false;
    };
    "qbt" = {
      port = webUIPort;
      host = containerIP;
      authMessage = "Stop Right There, Criminal Scum!";
    };
  };

  services.vpnContainers.torrents = rec {
    ipPrefix = "192.168.1";
    storageUsers = {
      downloads = [ "qbittorrent" ];
    };
    config = { config, pkgs, ... }: {
      imports = [
        ../modules/qbittorrent.nix
        ../modules/flood.nix
      ];

      services = {
        flood = {
          enable = true;
          port = floodUIPort;
          host = containerIP;
          baseURI = "/flood/";
          allowedPaths = [ "/mnt/downloads" ];
          qbURL = "http://127.0.0.1:${toString webUIPort}";
          qbUser = "admin";
          qbPass = "adminadmin";
          user = "qbittorrent";
          group = "qbittorrent";
        };
        qbittorrent = {
          enable = true;
          port = webUIPort;
        };
      };

      networking = {
        firewall.allowedTCPPorts = [ webUIPort floodUIPort ];
      };
    };
  };
}