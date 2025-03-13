{ lib, ... }:
let
  port = 6969;
in
{
  imports = [
    ../modules/hath.nix
  ];

  services.watcher-bot.plugins = [ "${../../_common/constants/watcher}/hath_dl_done" ];

  users.groups.syncthing.members = [ "hath" ];

  services.hath = {
    enable = true;
    cacheDir = "/home/hath/cache";
    downloadDir = "/sync/downloads/hath";
    port = port;
    group = "syncthing";
  };

  networking.firewall = {
    allowedTCPPorts = [ port ];
  };
  custom.ipset-block.exceptPorts = [ port ];
}
