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

  errorPageDirectives = "error_page ${concatStringsSep " " (attrNames statusCodes)} /error.html;";
  errorPageOpts = {
    extraConfig = ''
      ${errorPageDirectives}
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
  denyWriteMethods = "limit_except GET PROPFIND OPTIONS { deny all; }";

  proxyCfg = config.services.nginxProxy;
  proxyPathOpts = { name, ... }: {
    options = {
      serverHost = mkOption {
        description = "The host for the generated server block";
        default = "${name}.durga.withsam.org";
        type = types.str;
      };
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
        description = "Extra config to add to the @default location block";
        default = "";
        type = types.str;
      };
      extraServerConfig = mkOption {
        description = "Extra config to add to the server block";
        default = "";
        type = types.str;
      };
      authMessage = mkOption {
        description = "The message to display when prompting for authorization";
        default = "Restricted area";
        type = types.str;
      };
      useAuth = mkOption {
        description = "Whether or not to use basic authorisation";
        default = true;
        type = types.bool;
      };
      secureLinks = mkOption {
        description = "Whether or not to enable shareable secure linking via nginx's secure_link module, only works if authentication is enabled";
        default = false;
        type = types.bool;
      };
      secureLinkParam = mkOption {
        description = "The query parameter to use for the secure link token";
        default = "sl_token";
        type = types.str;
      };
    };
  };

  # TODO: fix njs build
  secureLinkEnable = false;
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
    custom.ipset-block.exceptPorts = [ 443 ];

    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      certs = {
        "durga.withsam.org" = {
          email = "tabhooked@gmail.com";
          extraDomainNames = [ "*.durga.withsam.org" "piracy.withsam.org" "music.withsam.org" "l.withsam.org" ];
          dnsProvider = "ovh";
          credentialsFile = "/var/lib/secrets/ovh.certs.secret";
        };
      };
    };

    users.groups.acme.members = [ "nginx" ];

    systemd.services.nginx.serviceConfig.EnvironmentFile = "/var/lib/nginx/nginx.env";

    services.nginx = {
      enable = true;

      # TODO: fix njs build
      # additionalModules = [ pkgs.nginxModules.njs ];

      appendConfig = ''
        env SL_SECRET_KEY;
      '';

      appendHttpConfig =
        let
          lines = concatStringsSep "\n" (mapAttrsToList (k: v: "${k} ${lib.strings.escapeNixString v};") statusCodes);
        in
        ''
          charset utf-8;

          map $status $status_text {
            ${lines}
            default "Something went wrong";
          }

          access_log syslog:server=unix:/dev/log;
          log_format   main '$remote_addr - $remote_user [$time_local] $status '
            '"$request" $body_bytes_sent "$http_referer" '
            '"$http_user_agent" "$http_x_forwarded_for"';

          #js_import sl_helper from ${../constants/secure_link_helper.js};

          #js_set $sl_arg_token sl_helper.arg_token;
          #js_set $sl_hashable_url sl_helper.hashable_url;
          #js_set $sl_expected_hash sl_helper.expected_hash;
          #js_set $sl_shareable_url sl_helper.shareable_url;
        '';

      virtualHosts = mkMerge ([
        {
          # default server block (i.e. wrong/no domain)
          "_" = {
            default = true;
            addSSL = true;
            useACMEHost = "durga.withsam.org";
            root = "/var/www";

            extraConfig = ''
              types { } default_type "text/plain; charset=utf-8";
              add_header Content-Encoding "gzip, gzip";
              try_files /100g_9_9.gzip.gzip =444;
            '';
          };

          "www.durga.withsam.org" = {
            useACMEHost = "durga.withsam.org";
            forceSSL = true;
            extraConfig = ''
              rewrite ^/$ https://durga.withsam.org permanent;
            '';
          };

          "durga.withsam.org" = addErrorPageOpts {
            useACMEHost = "durga.withsam.org";
            forceSSL = true;
            root = "/dev/null";

            locations = {
              "/".extraConfig = ''
                rewrite ^ https://blog.withsam.org;
              '';
            };
          };

          "piracy.withsam.org" = addErrorPageOpts {
            useACMEHost = "durga.withsam.org";
            forceSSL = true;
            root = "/var/www/files";
            extraConfig = "dav_ext_methods PROPFIND OPTIONS;";
            locations = {
              "/".extraConfig = ''
                ${denyWriteMethods}
                # prevent viewing directories without auth
                if ($request_method = PROPFIND) {
                  rewrite ^(.*[^/])$ $1/ last; 
                }
              '';
              "~ .*/$".extraConfig = ''
                ${denyWriteMethods}
                autoindex on;
                auth_basic "Keep trying";
                auth_basic_user_file /var/lib/nginx/auth/files.htpasswd;
              '';
            };
          };

          "music.withsam.org" = addErrorPageOpts {
            useACMEHost = "durga.withsam.org";
            forceSSL = true;
            root = "/var/www/files/music";
            extraConfig = "dav_ext_methods PROPFIND OPTIONS;";
            locations = {
              "/".extraConfig = ''
                ${denyWriteMethods}
                autoindex on;
                auth_basic "An otter in my water?";
                auth_basic_user_file /var/lib/nginx/auth/music.htpasswd;
              '';
            };
          };
        }
      ] ++ (
        mapAttrsToList
          (path: opts: {
            "${opts.serverHost}" = addErrorPageOpts {
              useACMEHost = "durga.withsam.org";
              forceSSL = true;
              extraConfig = ''
                ${optionalString (opts.secureLinks && opts.useAuth) ''
                set $sl_param "${opts.secureLinkParam}";
                ''}
                ${opts.extraServerConfig}
              '';
              locations."= /favicon.ico".extraConfig = "try_files /dev/null @default;";
              locations."/".extraConfig = "try_files /dev/null @default;";
              locations."@default".extraConfig = ''
                ${optionalString (opts.secureLinks && opts.useAuth && secureLinkEnable) ''
                error_page 463 = @auth_success;
                ${errorPageDirectives}
                set $sl_param "${opts.secureLinkParam}";
                secure_link $sl_arg_token;
                secure_link_md5 $sl_hashable_url;

                set $skip_auth "$secure_link;$request_method";
                if ($skip_auth = "1;GET") {
                  return 463;
                }
                ''}

                ${optionalString opts.useAuth ''
                auth_basic "${opts.authMessage}";
                auth_basic_user_file /var/lib/nginx/auth/${path}.htpasswd;
                ''}

                try_files /dev/null @auth_success;
              '';
              locations."@auth_success".extraConfig = ''
                ${optionalString (opts.secureLinks && opts.useAuth && secureLinkEnable) ''
                set $provided_token $sl_arg_token;
                if ($provided_token = "") {
                  set $provided_token $sl_expected_hash;
                }
                if ($provided_token != $sl_expected_hash) {
                  rewrite ^ $sl_shareable_url? redirect;
                }
                ''}

                proxy_pass http://${opts.host}:${toString opts.port};
                proxy_set_header X-Forwarded-Host $host;
                proxy_set_header X-Forwarded-Proto $scheme;
                ${opts.extraConfig}
              '';
            };
          })
          proxyCfg.paths
      ));

    };
  };
}
