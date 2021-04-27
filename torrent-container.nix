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
          # rtorrent = {
          #   enable = true;
          #   downloadDir = "/mnt/downloads/complete";
          #   package = (pkgs.callPackage ./packages/rtorrent-jesec.nix {});
          # };
        };

        services.openvpn.servers = {
          torrentVPN = {
            config = '' config /mnt/data/openvpn/torrentVPN.conf '';
          };
        };

        networking = {
          enableIPv6 = false;
          nameservers = [ "8.8.8.8" ];

          # We don't need extraStopCommands because the whole container gets restarted
          # when the config is updated
          firewall.extraCommands = ''
            # accept anything from openvpn group
            iptables -A OUTPUT -j ACCEPT -m owner --gid-owner openvpn

            # allow vpn server
            iptables -A OUTPUT -d ***REMOVED***/32 -j ACCEPT

            # allow loopback and tunnel
            iptables -A OUTPUT -j ACCEPT -o lo
            iptables -A OUTPUT -j ACCEPT -o tun+

            # allow lan IPs
            iptables -A INPUT -s ${vlanSubnet}/24 -j ACCEPT
            iptables -A OUTPUT -d ${vlanSubnet}/24 -j ACCEPT

            # allow replies to established connections
            iptables -A INPUT -j ACCEPT -m state --state ESTABLISHED

            # drop everything else
            iptables -P OUTPUT DROP
            iptables -P INPUT DROP
          '';
        };
      };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-torrents" ];
    externalInterface = "eth0";
  };
}