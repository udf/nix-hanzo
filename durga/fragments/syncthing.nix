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

  users.users.sam.extraGroups = [ "syncthing" ];
  users.users.syncthing.extraGroups = [ "cl_qbit" "cl_music" "cl_backups" "factorio" ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 204800;
  };
}
