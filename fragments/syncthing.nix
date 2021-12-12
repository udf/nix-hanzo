{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "syncthing";
    dataDir = "/home/syncthing";
    configDir = "/home/syncthing/.config/syncthing";
    openDefaultPorts = true;
  };

  services.nginxProxy.paths = {
    "syncthing" = {
      port = 8384;
      authMessage = "What are you doing in my swamp?!";
      extraConfig = ''
        include /var/lib/secrets/nginx-syncthing-pw.conf;
      '';
    };
  };

  utils.storageDirs = {
    dirs = {
      music = { users = [ "syncthing" ]; };
      downloads = { users = [ "syncthing" ]; };
      backups = { users = [ "syncthing" ]; };
    };
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 204800;
  };
}