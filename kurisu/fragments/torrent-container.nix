{ config, lib, pkgs, ... }:
with lib;
let
  ipPrefix = "192.168.1";
  containerIP = "${ipPrefix}.2";
  ports = {
    qbit = { internal = 8080; external = 18080; };
    flood = { internal = 3000; external = 13000; };
  };
in
{
  imports = [
    ../modules/vpn-containers.nix
  ];

  services.nginxProxy.paths = {
    "flood" = {
      port = ports.flood.external;
      host = containerIP;
      authMessage = "What say you in your defense?";
      extraConfig = ''
        include /var/lib/secrets/nginx-torrents/proxy-pw.conf;
      '';
    };
    "qbt" = {
      port = ports.qbit.external;
      host = containerIP;
      authMessage = "Stop Right There, Criminal Scum!";
      extraConfig = ''
        include /var/lib/secrets/nginx-torrents/proxy-pw.conf;
      '';
    };
  };

  services.backup-root.excludePaths = [ "/var/lib/containers/torrents/var/lib/qbittorrent/in_progress" ];

  services.vpnContainers.torrents = rec {
    ipPrefix = "192.168.1";
    storageUsers = {
      downloads = [ "qbittorrent" ];
    };
    bindMounts = {
      "/mnt/secrets" = {
        hostPath = "/var/lib/secrets/nginx-torrents";
      };
    };
    config = { config, pkgs, ... }: {
      imports = [
        ../modules/qbittorrent.nix
        ../modules/flood.nix
      ];

      services = {
        flood = {
          enable = true;
          port = ports.flood.internal;
          host = "0.0.0.0";
          baseURI = "/";
          allowedPaths = [ "/mnt/downloads" "/var/lib/qbittorrent" ];
          qbURL = "http://127.0.0.1:${toString ports.qbit.internal}";
          qbUser = "admin";
          qbPass = "adminadmin";
          user = "qbittorrent";
          group = "qbittorrent";
        };
        qbittorrent = {
          enable = true;
          port = ports.qbit.internal;
        };
        nginx = {
          enable = true;
          virtualHosts = mkMerge (mapAttrsToList
            (name: ports: {
              "${name}" = {
                listen = [{ addr = containerIP; port = ports.external; }];
                locations."/" = {
                  proxyPass = "http://127.0.0.1:${toString ports.internal}";
                  basicAuthFile = "/mnt/secrets/.htpasswd";
                };
              };
            })
            ports);
        };
        watcher-bot.plugins = [ "systemd" "status" "flood" ];
      };

      networking = {
        firewall.allowedTCPPorts = [ ports.flood.external ports.qbit.external ];
      };
    };
  };
}
