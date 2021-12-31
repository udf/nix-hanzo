{ config, lib, pkgs, ...}:
let
  vpnConsts = config.consts.vpn;
in
{
  imports = [
    ../constants/vpn.nix
    ../modules/vpn-containers.nix
  ];

  utils.storageDirs.dirs = {
    hath = { path = "/backups/hath"; };
  };

  services.vpnContainers.hath = {
    ipPrefix = "192.168.2";
    storageUsers = {
      hath = [ "hath" ];
      downloads = [ "hath" ];
    };
    config = { config, pkgs, ... }: {
      imports = [
        ../modules/hath.nix
        ../modules/watcher-bot.nix
      ];

      services.hath = {
        enable = true;
        cacheDir = "/mnt/hath/cache";
        downloadDir = "/mnt/downloads/sync/hath";
        port = vpnConsts.clients.hath.forwardedTCPPorts.hath; 
      };
    };
  };
}