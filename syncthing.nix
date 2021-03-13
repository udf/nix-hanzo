{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "syncthing";
    group = "storage";
    dataDir = "/home/syncthing";
    configDir = "/home/syncthing/.config/syncthing";
    openDefaultPorts = true;
  };

  services.nginxProxy.paths = {
    "syncthing" = {
      port = 8384;
      authMessage = "What are you doing in my swamp?!";
    };
  };
}