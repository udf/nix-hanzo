{ config, lib, pkgs, ... }:
let
  port = 4533;
in
{
  imports = [
    ../modules/navidrome.nix
  ];

  services.navidrome = {
    enable = true;
    settings = {
      LogLevel = "INFO";
      BaseURL = "/navidrome";
      ScanInterval = "60s";
      TranscodingCacheSize = "128MB";
      MusicFolder = "/booty/music";
      Port = port;
      Address = "localhost";
      EnableTranscodingConfig = "true";
    };
  };

  services.nginxProxy.paths = {
    "navidrome" = {
      port = port;
      authMessage = "Are you noug navidrome owner of the nimmsdale navidrome?";
      rewrite = false;
      extraConfig = ''
        proxy_max_temp_file_size 0;
      '';
    };
  };

  utils.storageDirs.dirs.music.users = [ "navidrome" ];
}