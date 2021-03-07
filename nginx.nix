{ config, lib, pkgs, ... }:
with lib;
let
  statusCodes = {
    "400" = "Bad Request";
    "401" = "Unauthorized";
    "402" = "Payment Required";
    "403" = "Forbidden";
    "404" = "Not Found";
    "405" = "Method Not Allowed";
    "406" = "Not Acceptable";
    "407" = "Proxy Authentication Required";
    "408" = "Request Timeout";
    "409" = "Conflict";
    "410" = "Gone";
    "411" = "Length Required";
    "412" = "Precondition Failed";
    "413" = "Payload Too Large";
    "414" = "Request URI Too Long";
    "415" = "Unsupported Media Type";
    "416" = "Requested Range Not Satisfiable";
    "417" = "Expectation Failed";
    "418" = "I'm a teapot";
    "421" = "Misdirected Request";
    "422" = "Unprocessable Entity";
    "423" = "Locked";
    "424" = "Failed Dependency";
    "425" = "Too Early";
    "426" = "Upgrade Required";
    "428" = "Precondition Required";
    "429" = "Too Many Requests";
    "431" = "Request Header Fields Too Large";
    "451" = "Unavailable For Legal Reasons";
    "500" = "Internal Server Error";
    "501" = "Not Implemented";
    "502" = "Bad Gateway";
    "503" = "Service Unavailable";
    "504" = "Gateway Timeout";
    "505" = "HTTP Version Not Supported";
    "506" = "Variant Also Negotiates";
    "507" = "Insufficient Storage";
    "508" = "Loop Detected";
    "510" = "Not Extended";
    "511" = "Network Authentication Required";
    "599" = "Network Connect Timeout Error";
  };
  mapAttrsToStr = sep: fn: set: lib.strings.concatStringsSep sep (lib.mapAttrsToList fn set);

  nginxStrEscape = s: lib.strings.escape [ "\"" "\\" ] s;
  proxyCfg = config.services.nginxProxy;
  proxyPathOpts = { path, ...}: {
    options = {
      port = mkOption {
        description = "The local port to proxy";
        type = types.port;
      };
      authMessage = {
        description = "The message to display when prompting for authorization";
        default = "Restricted area";
        type = types.str;
      };
    };
  };
in
{
  options.services.nginxProxy = {
    paths = mkOption {
      description = "Set of paths that will be proxied (without leading/trailing slashes)";
      type = types.attrsOf (types.submodule proxyPathOpts);
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      certs = {
        "tsunderestore.io".email = "tabhooked@gmail.com";
      };
    };

    services.nginx = {
      enable = true;

      appendHttpConfig = let
        lines = mapAttrsToStr "\n" (k: v: "${k} ${lib.strings.escapeNixString v};") statusCodes;
      in ''
        map $status $status_text {
          ${lines}
          default "Something went wrong";
        }

        access_log syslog:server=unix:/dev/log;
        log_format   main '$remote_addr - $remote_user [$time_local] $status '
          '"$request" $body_bytes_sent "$http_referer" '
          '"$http_user_agent" "$http_x_forwarded_for"';
      '';

      virtualHosts."tsunderestore.io" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/";

        extraConfig = let
            codes = mapAttrsToStr " " (k: v: "${k}") statusCodes;
          in "error_page ${codes} /error.html;";

        locations = {
          "/error.html".extraConfig = ''
            ssi on;
            internal;
          '';

          "/food".extraConfig = ''
            return 410;
          '';
        } // lib.attrsets.mapAttrs' (
          path: opts: {
            name = "/${path}/";
            value = {
              proxyPass = "https://127.0.0.1:${opts.port}";
              extraConfig = ''
                rewrite /${path}/(.*) /$1 break;
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_set_header X-Forwarded-Prefix syncthing;
                auth_basic "${nginxStrEscape opts.authMessage}";
                auth_basic_user_file /var/www/${path}/.htpasswd;
              '';
            };
          }) proxyCfg.paths;
      };
    };
  };
}
