{ config, lib, pkgs, ... }:
let
  port = 4040;
  airsonicPkg = (pkgs.callPackage ../packages/airsonic-advanced.nix {});
in
{
  services.airsonic = {
    enable = true;
    contextPath = "/";
    maxMemory = 1024;
    port = port;
    jre = pkgs.openjdk11;
    war = "${airsonicPkg}/webapps/airsonic.war";
    jvmOptions = [
      "-Dserver.forward-headers-strategy=native"
    ];
  };

  systemd.services.airsonic = {
    path = [ pkgs.ffmpeg ];
  };

  services.nginxProxy.paths = {
    "airsonic" = {
      port = port;
      authMessage = "Thank you for flying with Air Sonic";
      extraConfig = ''
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header Host $host;
        proxy_max_temp_file_size 0;
        proxy_redirect http:// https://;
        proxy_buffering off;
        proxy_request_buffering off;
        client_max_body_size 0;
        proxy_set_header Authorization "";
      '';
    };
  };

  utils.storageDirs.dirs.music.users = [ "airsonic" ];
}