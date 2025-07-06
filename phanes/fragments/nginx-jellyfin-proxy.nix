{ config, lib, pkgs, ... }:
let
  serverHost = (import ../../_common/constants/private.nix).homeHostname;
  util = (import ../../_common/helpers/nginx-util.nix) { inherit lib pkgs; };
  upstreamHost = "192.168.0.2:8096";
  commonOptions = ''
    proxy_connect_timeout 5s;
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Protocol $scheme;
    proxy_set_header X-Forwarded-Host $http_host;
  '';
in
{
  # based on https://wiki.archlinux.org/title/Jellyfin#Nginx_reverse_proxy
  services.nginx.virtualHosts = {
    "jellyfun.${serverHost}" = util.addErrorPageOpts {
      useACMEHost = serverHost;
      forceSSL = true;
      extraConfig = ''
        client_max_body_size 20M;

        # Security / XSS Mitigation Headers
        add_header X-Content-Type-Options "nosniff";
      '';
      locations = {
        "/".extraConfig = ''
          try_files _ @default;
        '';

        # Proxy main Jellyfin traffic
        "@default".extraConfig = ''
          proxy_pass http://${upstreamHost};
          ${commonOptions}

          # Disable buffering when the nginx proxy gets very resource heavy upon streaming
          proxy_buffering off;
        '';

        # location block for /web - This is purely for aesthetics so /web/#!/ works instead of having to go to /web/index.html/#!/
        "= /web/".extraConfig = ''
          # Proxy main Jellyfin traffic
          proxy_pass http://${upstreamHost}/web/index.html;
          ${commonOptions}
        '';

        # Proxy Jellyfin Websockets traffic
        "^~ /socket".extraConfig = ''
          proxy_pass http://${upstreamHost};
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          ${commonOptions}
        '';
      };
    };
  };
}
