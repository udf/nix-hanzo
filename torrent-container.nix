{ config, lib, pkgs, ... }:
let
  vlanSubnet = "192.168.1.0";
  hostIP = "192.168.1.1";
  containerIP = "192.168.1.2";
  webUIPort = 8080;
  floodUIPort = 3000;
in
{
  # manually specify GID so the group can have the same ID inside the container
  utils.storageDirs = {
    dirs = {
      downloads = { gid = 995; };
    };
  };
  # TODO: automate setting same uid/gid inside and outside of container
  users = {
    users = {
      qbittorrent = { uid = 10002; };
    };
    groups = {
      qbittorrent = { gid = 10002; };
    };
  };

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

  containers.torrents = {
    autoStart = true;
    enableTun = true;
    privateNetwork = true;
    hostAddress = hostIP;
    localAddress = containerIP;
    bindMounts = {
      "/mnt/data" = {
        hostPath = "/var/lib/container_data/torrents";
        isReadOnly = true;
      };
      "/mnt/downloads" = {
        hostPath = "${config.utils.storageDirs.storagePath}/downloads";
        isReadOnly = false;
      };
    };
    config = let
      hostCfg = config;
    in
      { config, pkgs, ... }:
      {

        imports = [
          ./modules/qbittorrent.nix
          ./modules/flood.nix
        ];

        environment.systemPackages = with pkgs; [
          tree
          file
          htop
          wireguard
        ];

        users = {
          groups = {
            openvpn = {};
            st_downloads = {
              gid = hostCfg.users.groups.st_downloads.gid;
              members = [ "qbittorrent" ];
            };
            qbittorrent = {
              gid = hostCfg.users.groups.qbittorrent.gid;
            };
          };
          users = {
            qbittorrent = {
              uid = hostCfg.users.users.qbittorrent.uid;
            };
          };
        };

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
          enableIPv6 = false;
          nameservers = [ "8.8.8.8" ];
          firewall.allowedTCPPorts = [ 10810 ];
          firewall.allowedUDPPorts = [ 51820 ];
          # poor man's killswitch
          firewall.extraCommands = ''
            ip route del default
          '';
        };

        networking.wireguard.interfaces = {
          wg0 = {
            ips = [ "10.100.0.2/24" ];
            listenPort = 51820;
            privateKeyFile = "/root/wireguard-keys/private";

            postSetup = ''
              ip route add ***REMOVED*** via ${hostIP} dev eth0
            '';
            postShutdown = ''
              ip route del ***REMOVED*** via ${hostIP} dev eth0
            '';

            peers = [
              {
                publicKey = "nJnRKVLUwW+D2h/rhbF0o69IWfccK/8SJJuNvg7GkgA=";
                allowedIPs = [ "0.0.0.0/0" ];
                endpoint = "***REMOVED***:51820";
                persistentKeepalive = 25;
              }
            ];
          };
        };
      };
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [ wireguard ];

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-torrents" ];
    externalInterface = "eth0";
  };
}