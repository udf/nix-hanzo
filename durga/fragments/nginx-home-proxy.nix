{ config, lib, pkgs, ... }:
let
  homeHostname = (import ../../_common/constants/private.nix).homeHostname;
  serverHost = "durga.withsam.org";
  proxySubdomain = "gaia";
  subMap = "$sub_subdomain_${proxySubdomain}";
  util = (import ../../_common/helpers/nginx-util.nix) { inherit lib pkgs; };
in
{
  security.acme.certs."${serverHost}".extraDomainNames = [
    "*.${proxySubdomain}.withsam.org"
  ];

  services.nginx = {
    commonHttpConfig = ''
      map $host ${subMap} {
        "~^(music)\.${proxySubdomain}\.withsam\.org$" "$1.${homeHostname}";
        default "DENY";
      }
      map $uri $uri_is_dir {
        ~/$ "1";
        default "0";
      }
      map $args $args_has_embed {
        ~(?:^|&)embed(?:[=&]|$) "1";
        default "0";
      }
    '';

    virtualHosts."*.${proxySubdomain}.withsam.org" = util.addErrorPageOpts {
      useACMEHost = serverHost;
      forceSSL = true;
      locations = {
        "/".extraConfig = ''
          try_files _ @default;
        '';

        "@deny".extraConfig = util.gzipBombConfig;

        "@default".extraConfig = ''
          # using 444 as the error page code closes the connection after getting to the @deny block
          # this is really really stupid and hurts my brain, so use a 443 instead
          error_page 443 =200 @deny;
          if (${subMap} = "DENY") {
            return 443;
          }
          resolver 1.1.1.1;

          # don't let clients close the keep-alive connection to upstream. See the nginx blog for details:
          # https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/#no-keepalives
          proxy_http_version 1.1;
          proxy_set_header "Connection" "";

          proxy_connect_timeout 20s;
          proxy_send_timeout 20s;
          proxy_read_timeout 20s;

          proxy_cache diskcache; 
          proxy_cache_key "$scheme$host$uri$args_has_embed";
          proxy_cache_bypass $arg_nocache;
          proxy_no_cache $uri_is_dir;
          proxy_cache_lock on;
 	        proxy_cache_lock_age 5s;

          proxy_cache_valid 200 36500d;
          proxy_cache_valid any 5s;

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
