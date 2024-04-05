{ ... }:
let
  port = 6969;
in
{
  imports = [
    ../modules/hath.nix
  ];

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
}