{ config, lib, pkgs, ... }:
let
  httpPort = 1984;
  rtmpPort = 1935;
in
{
  services.owncast = {
    enable = true;
    port = httpPort;
    rtmp-port = rtmpPort;
  };

  networking.firewall = {
    allowedTCPPorts = [ rtmpPort ];
  };

  services.nginxProxy.paths = {
    "pwncast" = {
      port = httpPort;
      useAuth = false;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Server $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header  Authorization $http_authorization;
        proxy_pass_header Authorization;
      '';
    };
  };
}
