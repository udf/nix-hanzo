# Module to generate nixos containers that use the vpn server as their only
# internet connection
{ config, lib, pkgs, ... }:
with lib;
let
  containerOpts = { ... }: {
    options = {
      ipPrefix = mkOption {
        description = "Local (host network) IP prefix of the container, excluding last octet";
        example = "192.168.1";
        type = types.str;
      };
      storageUsers = mkOption {
        description = "Map of storage dirs to list of allowed users";
        type = types.attrsOf (types.listOf types.str);
        default = { };
      };
      bindMounts = mkOption {
        description = "Additional bind mounts";
        type = types.unspecified;
        default = { };
      };
      config = mkOption {
        description = "The configuration of this container, as a NixOS module.";
        type = types.unspecified;
      };
    };
  };
  cfg = config.services.vpnContainers;
  vpnConsts = config.consts.vpn;
  # https://gist.github.com/udf/4d9301bdc02ab38439fd64fbda06ea43
  mkMergeTopLevel = names: attrs: getAttrs names (
    mapAttrs (k: v: mkMerge v) (foldAttrs (n: a: [ n ] ++ a) [ ] attrs)
  );
  topLevelConfig = {
    networking.nat.internalInterfaces = [ "ve-+" ];
  };
in
{
  imports = [
    ../../_common/constants/vpn.nix
    ../../_common/fragments/deterministic-ids.nix
  ];

  options.services.vpnContainers = mkOption {
    description = "Set of containers to create";
    type = types.attrsOf (types.submodule containerOpts);
  };

  config = (mkMergeTopLevel [ "users" "networking" "containers" ] ((mapAttrsToList
    (
      name: opts: {
        # Create users and groups on host so file owners make sense
        # deterministic-ids.nix ensures that we have the same ids inside and outside of the container
        users =
          let
            userNames = flatten (attrValues opts.storageUsers);
          in
          {
            users = (genAttrs
              userNames
              (u: { isSystemUser = true; group = u; })
            );
            groups = (genAttrs
              userNames
              (u: { })
            );
          };

        containers."${name}" = {
          autoStart = true;
          enableTun = true;
          privateNetwork = true;
          hostAddress = "${opts.ipPrefix}.1";
          localAddress = "${opts.ipPrefix}.2";
          bindMounts = opts.bindMounts;
          config = { config, pkgs, ... }: {
            imports = [
              ../../_common/fragments/deterministic-ids.nix
              ../../_common/modules/watcher-bot.nix
              opts.config
            ];

            environment.systemPackages = with pkgs; [
              tree
              file
              htop
              wireguard-tools
            ];

            services.journald.extraConfig = ''
              MaxRetentionSec=1week
              SystemMaxUse=1G
            '';

            users = {
              users = (genAttrs
                (flatten (attrValues opts.storageUsers))
                (u: { isSystemUser = true; group = mkDefault u; })
              );
              groups = mkMerge (mapAttrsToList
                (dir: users: {
                  "st_${dir}".members = users;
                })
                opts.storageUsers);
            };

            networking = {
              enableIPv6 = false;
              nameservers = [ "1.1.1.1" ];
              firewall.allowedTCPPorts = (attrValues vpnConsts.clients."${name}".forwardedTCPPorts);
              firewall.allowedUDPPorts = [ vpnConsts.serverPort ] ++ (attrValues vpnConsts.clients."${name}".forwardedUDPPorts);
              # poor man's killswitch
              firewall.extraCommands = ''
                ${pkgs.iproute}/bin/ip route del default
              '';
            };

            networking.wireguard.interfaces = {
              wg0 = {
                ips = [ "${vpnConsts.clients."${name}".ip}/24" ];
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
        };
      }
    )
    cfg) ++ [topLevelConfig]));
}
