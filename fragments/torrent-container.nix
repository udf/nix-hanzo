{ config, lib, pkgs, ... }:
let
  vlanSubnet = "192.168.1.0";
  hostIP = "192.168.1.1";
  containerIP = "192.168.1.2";
  webUIPort = 8080;
  floodUIPort = 3000;
  vpnConsts = import ../constants/vpn.nix;
in
{
  # Create qbittorrent user/group on host so file permissions make sense
  # deterministic-ids.nix ensures that we have the same ids inside and outside of the container
  users = {
    users = {
      qbittorrent = {};
    };
    groups = {
      qbittorrent = {};
    };
  };
  # probably isn't necessary
  utils.storageDirs.dirs.downloads.users = [ "qbittorrent" ];

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
          ../fragments/deterministic-ids.nix
          ../modules/qbittorrent.nix
          ../modules/flood.nix
          ./tg-spam.nix
        ];

        environment.systemPackages = with pkgs; [
          tree
          file
          htop
          wireguard
        ];

        users = {
          groups = {
            st_downloads = {
              members = [ "qbittorrent" ];
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
          firewall.allowedTCPPorts = [ vpnConsts.torrentListenPort ];
          firewall.allowedUDPPorts = [ vpnConsts.serverPort vpnConsts.torrentListenPort ];
          # poor man's killswitch
          firewall.extraCommands = ''
            ${pkgs.iproute}/bin/ip route del default
          '';
        };

        networking.wireguard.interfaces = {
          wg0 = {
            ips = [ "${vpnConsts.torrentContainerIP}/24" ];
            listenPort = vpnConsts.serverPort;
            privateKeyFile = "/root/wireguard-keys/private";

            postSetup = ''
              ip route add ${vpnConsts.serverIP} via ${hostIP} dev eth0
            '';
            postShutdown = ''
              ip route del ${vpnConsts.serverIP} via ${hostIP} dev eth0
            '';

            peers = [
              {
                publicKey = "nJnRKVLUwW+D2h/rhbF0o69IWfccK/8SJJuNvg7GkgA=";
                allowedIPs = [ "0.0.0.0/0" ];
                endpoint = "${vpnConsts.serverIP}:${toString vpnConsts.serverPort}";
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