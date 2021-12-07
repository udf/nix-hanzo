{ config, lib, pkgs, ... }:
let
  port = 4040;
in
{
  services.airsonic = {
    enable = true;
    contextPath = "/";
    maxMemory = 1024;
    port = port;
    jvmOptions = [
      "-Dserver.use-forward-headers=true"
    ];
  };

  services.nginxProxy.paths = {
    "airsonic" = {
      port = port;
      authMessage = "Thank you for flying with Air Sonic";
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_max_temp_file_size 0;
      '';
    };
  };

  utils.storageDirs.dirs.music.users = [ "airsonic" ];
}