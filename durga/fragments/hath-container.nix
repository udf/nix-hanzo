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
        hostPath = "/sync/downloads/hath";
        isReadOnly = false;
      };
    };
    config = { config, pkgs, ... }: {
      imports = [
        ../modules/hath.nix
      ];
      users.groups.syncthing.members = [ "hath" ];
      services.hath = {
        enable = true;
        cacheDir = "/home/hath/cache";
        downloadDir = "/mnt/downloads";
        port = vpnConsts.clients.hath.forwardedTCPPorts.hath;
        group = "syncthing";
      };
    };
  };
}
