{ config, lib, pkgs, ... }:
let
  homeHostname = (import ../../_common/constants/private.nix).homeHostname;
  serverHost = "durga.withsam.org";
  proxySubdomain = "gaia";
  subMap = "$sub_subdomain_${proxySubdomain}";
  util = (import ../../_common/helpers/nginx-util.nix) { inherit lib; };
in
{
  security.acme.certs."${serverHost}".extraDomainNames = [
    "*.${proxySubdomain}.withsam.org"
  ];

  services.nginx = {
    commonHttpConfig = ''
      map $host ${subMap} {
        "~^([^.]+)\.${proxySubdomain}\.withsam\.org$" "$1.${homeHostname}";
        default "DENY";
      }
    '';

    virtualHosts."*.${proxySubdomain}.withsam.org" = util.addErrorPageOpts {
      useACMEHost = serverHost;
      forceSSL = true;
      locations = {
        "/".extraConfig = ''
          try_files _ @default;
        '';

        "@default".extraConfig = ''
          if (${subMap} = "DENY") {
            return 400;
          }
          resolver 1.1.1.1;

          # don't let clients close the keep-alive connection to upstream. See the nginx blog for details:
          # https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#no-keepalives
          proxy_http_version 1.1;
          proxy_set_header "Connection" "";

          proxy_connect_timeout 20s;
          proxy_send_timeout 20s;
          proxy_read_timeout 20s;

          proxy_pass https://${subMap};
          proxy_intercept_errors off;
          proxy_set_header X-Forwarded-Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-For $remote_addr;
        '';
      };
    };
  };
}
