{ config, lib, pkgs, ... }:
let
  port = 4040;
in
{
  services.airsonic = {
    enable = true;
    contextPath = "/airsonic";
    maxMemory = 1024;
    port = port;
    jvmOptions = [
      "-Dserver.use-forward-headers=true"
      "-Dserver.contextPath=/airsonic" # module in nixpkgs was written by a retard
    ];
  };

  services.nginxProxy.paths = {
    "airsonic" = {
      port = port;
      authMessage = "Thank you for flying with Air Sonic";
      rewrite = false;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_max_temp_file_size 0;
      '';
    };
  };

  utils.storageDirs.dirs.music.users = [ "airsonic" ];
}