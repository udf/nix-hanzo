{ config, lib, pkgs, ... }:
with lib;
let
  ports = { qbit = 18080; flood = 3000; };
in
{
  services = {
    nginxProxy.paths = {
      "flood" = {
        port = ports.flood;
        authMessage = "What say you in your defense?";
      };
      "qbit" = {
        port = ports.qbit;
        authMessage = "Stop Right There, Criminal Scum!";
      };
    };

    flood = {
      enable = true;
      port = ports.flood;
      baseURI = "/";
      allowedPaths = [ "/cum/qbit" "/var/lib/qbittorrent" ];
      qbURL = "http://127.0.0.1:${toString ports.qbit}";
      qbUser = "admin";
      qbPass = "adminadmin";
      user = "qbittorrent";
      group = "cl_qbit";
    };
    qbittorrent = {
      enable = true;
      port = ports.qbit;
      group = "cl_qbit";
    };
    watcher-bot.plugins = [ "systemd" "status" "flood" ];
  };
}
