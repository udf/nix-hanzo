{ config, lib, pkgs, ... }:
let
  vpnConsts = config.consts.vpn;
in
{
  imports = [
    ../modules/vpn-containers.nix
  ];

  # TODO: take this out of a container
  services.vpnContainers.hath = {
    ipPrefix = "192.168.2";
    bindMounts = {
      "/mnt/downloads" = {
        hostPath = "/cum/qbit/sync/hath";
        isReadOnly = false;
      };
    };
    config = { config, pkgs, ... }: {
      imports = [
        ../modules/hath.nix
      ];
      users.groups.cl_qbit.members = [ "hath" ];
      services.hath = {
        enable = true;
        cacheDir = "/home/hath/cache";
        downloadDir = "/mnt/downloads";
        port = vpnConsts.clients.hath.forwardedTCPPorts.hath;
        group = "cl_qbit";
      };
    };
  };
}
