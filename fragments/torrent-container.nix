{ config, lib, pkgs, ... }:
with lib;
let
  vlanSubnet = "192.168.1.0";
  hostIP = "192.168.1.1";
  containerIP = "192.168.1.2";
  webUIPort = 8080;
  floodUIPort = 3000;
  vpnConsts = config.consts.vpn;
in
{
  imports = [
    ../constants/vpn.nix
  ];

  # Create qbittorrent user/group on host so file permissions make sense
  # deterministic-ids.nix ensures that we have the same ids inside and outside of the container
  users = {
    users = {
      qbittorrent = {};
      hath = {};
    };
    groups = {
      qbittorrent = {};
      hath = {};
    };
  };
  
  utils.storageDirs.dirs.downloads.users = [ "qbittorrent" ];
  utils.storageDirs.dirs.hath.users = [ "hath" ];

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
      "/mnt/hath" = {
        hostPath = "${config.utils.storageDirs.storagePath}/hath";
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
          ../modules/hath.nix
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
            st_downloads.members = [ "qbittorrent" ];
            st_hath.members = [ "hath" ];
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
          hath = {
            enable = true;
            cacheDir = "/mnt/hath/cache";
            downloadDir = "/mnt/hath/download";
            port = vpnConsts.clients.torrents.forwardedTCPPorts.hath;
            # tempDir = "/mnt/hath/tmp";
          };
        };

        networking = {
          enableIPv6 = false;
          nameservers = [ "8.8.8.8" ];
          firewall.allowedTCPPorts = [ webUIPort floodUIPort ] ++ (attrValues vpnConsts.clients.torrents.forwardedTCPPorts);
          firewall.allowedUDPPorts = [ vpnConsts.serverPort ] ++ (attrValues vpnConsts.clients.torrents.forwardedUDPPorts);
          # poor man's killswitch
          firewall.extraCommands = ''
            ${pkgs.iproute}/bin/ip route del default
          '';
        };

        networking.wireguard.interfaces = {
          wg0 = {
            ips = [ "${vpnConsts.clients.torrents.ip}/24" ];
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
                publicKey = vpnConsts.serverPublicKey;
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