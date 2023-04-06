{ config, lib, pkgs, ... }:
with lib;
let
  hostCfg = config;
  containersOpts = {
    "" = {
      ipPrefix = "192.168.1";
      externalPorts = { qbit = 18080; flood = 13000; };
    };
    "-priv" = {
      ipPrefix = "192.168.3";
      externalPorts = { qbit = 18081; flood = 13001; };
    };
  };
in
{
  imports = [
    ../modules/vpn-containers.nix
  ];

  services = mkMerge (mapAttrsToList
    (
      suffix: opts:
        let
          containerName = "torrents${suffix}";
          containerIP = "${opts.ipPrefix}.2";
          ports = {
            qbit = { internal = 8080; external = opts.externalPorts.qbit; };
            flood = { internal = 3000; external = opts.externalPorts.flood; };
          };
        in
        {
          nginxProxy.paths = {
            "flood${suffix}" = {
              port = ports.flood.external;
              host = containerIP;
              authMessage = "What say you in your defense?";
              extraConfig = ''
                include /var/lib/secrets/nginx-${containerName}/proxy-pw.conf;
              '';
            };
            "qbt${suffix}" = {
              port = ports.qbit.external;
              host = containerIP;
              authMessage = "Stop Right There, Criminal Scum!";
              extraConfig = ''
                include /var/lib/secrets/nginx-${containerName}/proxy-pw.conf;
              '';
            };
          };

          backup-root.excludePaths = [ "/var/lib/nixos-containers/${containerName}/var/lib/qbittorrent/in_progress" ];

          vpnContainers."${containerName}" = rec {
            ipPrefix = opts.ipPrefix;
            storageUsers = {
              downloads = [ "qbittorrent" ];
            };
            bindMounts = {
              "/mnt/secrets" = {
                hostPath = "/var/lib/secrets/nginx-${containerName}";
              };
              "/mnt/cloud" = {
                hostPath = "/cum/qbit";
                isReadOnly = false;
              };
            };
            config = { config, pkgs, ... }: {
              imports = [
                ../../_common/modules/qbittorrent.nix
                ../../_common/modules/flood.nix
              ];

              services = {
                flood = {
                  enable = true;
                  port = ports.flood.internal;
                  host = "0.0.0.0";
                  baseURI = "/";
                  allowedPaths = [ "/mnt/downloads" "/var/lib/qbittorrent" "/mnt/cloud" ];
                  qbURL = "http://127.0.0.1:${toString ports.qbit.internal}";
                  qbUser = "admin";
                  qbPass = "adminadmin";
                  user = "qbittorrent";
                  group = hostCfg.utils.storageDirs.dirs.downloads.group;
                };
                qbittorrent = {
                  enable = true;
                  port = ports.qbit.internal;
                  group = hostCfg.utils.storageDirs.dirs.downloads.group;
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
    )
    containersOpts);
}
