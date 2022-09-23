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

  errorPageOpts = {
    extraConfig = ''
      error_page ${concatStringsSep " " (attrNames statusCodes)} /error.html;
    '';

    locations = {
      "= /error.html".extraConfig = ''
        root /var/www;
        ssi on;
        internal;
      '';

      "~ \.(html|ico|webp|png)$".extraConfig = ''
        root /var/www;
        try_files $uri @default;
      '';

      "@default".extraConfig = "";
    };
  };
  addErrorPageOpts = opts: mkMerge [ errorPageOpts opts ];

  proxyCfg = config.services.nginxProxy;
  proxyPathOpts = { path, ... }: {
    options = {
      port = mkOption {
        description = "The local port to proxy";
        type = types.port;
      };
      host = mkOption {
        description = "The host to proxy";
        default = "127.0.0.1";
        type = types.str;
      };
      extraConfig = mkOption {
        description = "Extra config to add";
        default = "";
        type = types.str;
      };
      authMessage = mkOption {
        description = "The message to display when prompting for authorization";
        default = "Restricted area";
        type = types.str;
      };
      rewrite = mkOption {
        description = "Whether or not to rewrite the URL before calling the proxy";
        default = true;
        type = types.bool;
      };
    };
  };
in
{
  options.services.nginxProxy = {
    paths = mkOption {
      description = "Set of paths that will be proxied (without leading/trailing slashes)";
      type = types.attrsOf (types.submodule proxyPathOpts);
      default = { };
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      certs = {
        "withsam.org" = {
          email = "tabhooked@gmail.com";
          extraDomainNames = [ "*.withsam.org" ];
          dnsProvider = "ovh";
          credentialsFile = "/var/lib/secrets/ovh.certs.secret";
        };
      };
    };

    users.groups.acme.members = [ "nginx" ];
    utils.storageDirs.dirs = {
      downloads.readOnlyUsers = [ "nginx" ];
      music.readOnlyUsers = [ "nginx" ];
    };

    services.nginx = {
      enable = true;

      appendHttpConfig =
        let
          lines = concatStringsSep "\n" (mapAttrsToList (k: v: "${k} ${lib.strings.escapeNixString v};") statusCodes);
        in
        ''
          map $status $status_text {
            ${lines}
            default "Something went wrong";
          }

          access_log syslog:server=unix:/dev/log;
          log_format   main '$remote_addr - $remote_user [$time_local] $status '
            '"$request" $body_bytes_sent "$http_referer" '
            '"$http_user_agent" "$http_x_forwarded_for"';
        '';

      virtualHosts = mkMerge ([
        {
          # default server block (i.e. wrong/no domain)
          "_" = {
            default = true;
            addSSL = true;
            useACMEHost = "withsam.org";
            extraConfig = ''
              return 444;
            '';
          };

          "www.withsam.org" = {
            useACMEHost = "withsam.org";
            forceSSL = true;
            extraConfig = ''
              rewrite ^/$ https://withsam.org permanent;
            '';
          };

          "withsam.org" = addErrorPageOpts {
            useACMEHost = "withsam.org";
            forceSSL = true;
            root = "/var/www";

            locations = {
              "/".extraConfig = ''
                rewrite ^/$ https://blog.withsam.org;
              '';
            };
          };

          "files.withsam.org" = {
            useACMEHost = "withsam.org";
            forceSSL = true;
            root = "/var/www";
            extraConfig = ''
              rewrite ^/$ https://piracy.withsam.org permanent;
            '';
          };

          "piracy.withsam.org" = addErrorPageOpts {
            useACMEHost = "withsam.org";
            forceSSL = true;
            root = "/var/www/files";

            locations = {
              "~ .*/$".extraConfig = ''
                autoindex on;
                auth_basic "Keep trying";
                auth_basic_user_file /var/www/auth/files.htpasswd;
              '';
            };
          };
        }
      ] ++ (
        mapAttrsToList
          (path: opts: {
            "${path}.withsam.org" = addErrorPageOpts {
              useACMEHost = "withsam.org";
              forceSSL = true;
              locations."= /favicon.ico".extraConfig = "try_files /dev/null @default;";
              locations."/".extraConfig = "try_files /dev/null @default;";
              locations."@default" = {
                proxyPass = "http://${opts.host}:${toString opts.port}";
                extraConfig = ''
                  proxy_set_header X-Forwarded-Host $host;
                  proxy_set_header X-Forwarded-Proto $scheme;
                  auth_basic "${opts.authMessage}";
                  auth_basic_user_file /var/www/${path}/.htpasswd;
                  ${opts.extraConfig}
                '';
              };
            };
          })
          proxyCfg.paths
      ));

    };
  };
}
