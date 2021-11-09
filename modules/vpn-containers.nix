# Module to generate nixos containers that use the vpn server as their only
# internet connection
{ config, lib, pkgs, ...}:
with lib;
let
  mergeSets = (s: fold mergeAttrs {} s);

  containerOpts = {...}: {
    options = {
      ipPrefix = mkOption {
        description = "Local (host network) IP prefix of the container, excluding last octet";
        example = "192.168.1";
        type = types.str;
      };
      storageUsers = mkOption {
        description = "Map of storage dirs to list of allowed users";
        type = types.attrsOf (types.listOf types.str);
        default = {};
      };
      config = mkOption {
        description = "";
        type = types.unspecified;
      };
    };
  };
  cfg = config.services.vpnContainers;
  vpnConsts = config.consts.vpn;
in
{
  imports = [
    ../constants/vpn.nix
    ../fragments/deterministic-ids.nix
  ];

  options.services.vpnContainers = mkOption {
    description = "Set of containers to create";
    type = types.attrsOf (types.submodule containerOpts);
  };

  config = {
    # Create users and groups on host so file permissions make sense
    # deterministic-ids.nix ensures that we have the same ids inside and outside of the container
    users.users = mergeSets (forEach
      (flatten (map (f: attrValues f.storageUsers) (attrValues cfg)))
      (u: { "${u}" = { isSystemUser = true; }; })
    );

    utils.storageDirs.dirs = (mapAttrs
      (name: value: { users = value; })
      (foldAttrs concat [] (catAttrs "storageUsers" (attrValues cfg)))
    );

    networking.nat = {
      internalInterfaces = map (n: "ve-${n}") (attrNames cfg);
    }; 

    containers = attrsets.mapAttrs (containerName: opts: {
      autoStart = true;
      enableTun = true;
      privateNetwork = true;
      hostAddress = "${opts.ipPrefix}.1";
      localAddress = "${opts.ipPrefix}.2";
      bindMounts = attrsets.mapAttrs' (dirName: users: {
        name = "/mnt/${dirName}";
        value = {
          hostPath = "${config.utils.storageDirs.storagePath}/${dirName}";
          isReadOnly = false;
        };
      }) opts.storageUsers;
      config = { config, pkgs, ...}: {
        imports = [
          ../fragments/deterministic-ids.nix
          opts.config
        ];

        environment.systemPackages = with pkgs; [
          tree
          file
          htop
          wireguard
        ];

        users = {
          users = mergeSets (forEach
            (flatten (attrValues opts.storageUsers))
            (u: { "${u}" = {}; })
          );
          groups = attrsets.mapAttrs' (dirName: users: 
            nameValuePair "st_${dirName}" { members = users; }
          ) opts.storageUsers;
        };

        networking = {
          enableIPv6 = false;
          nameservers = [ "8.8.8.8" ];
          firewall.allowedTCPPorts = (attrValues vpnConsts.clients."${containerName}".forwardedTCPPorts);
          firewall.allowedUDPPorts = [ vpnConsts.serverPort ] ++ (attrValues vpnConsts.clients."${containerName}".forwardedUDPPorts);
          # poor man's killswitch
          firewall.extraCommands = ''
            ${pkgs.iproute}/bin/ip route del default
          '';
        };

        networking.wireguard.interfaces = {
          wg0 = {
            ips = [ "${vpnConsts.clients."${containerName}".ip}/24" ];
            listenPort = vpnConsts.serverPort;
            privateKeyFile = "/root/wireguard-keys/private";

            postSetup = ''
              ip route add ${vpnConsts.serverIP} via ${opts.ipPrefix}.1 dev eth0
            '';
            postShutdown = ''
              ip route del ${vpnConsts.serverIP} via ${opts.ipPrefix}.1 dev eth0
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
    }) cfg;
  };
}