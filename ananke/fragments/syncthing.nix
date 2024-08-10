{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "syncthing";
    dataDir = "/home/syncthing";
    configDir = "/home/syncthing/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
  };

  users.users.sam.extraGroups = [ "syncthing" ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 204800;
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
