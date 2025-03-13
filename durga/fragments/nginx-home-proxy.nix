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
