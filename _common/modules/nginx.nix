{ config, lib, pkgs, ... }:
with lib;
let
  util = (import ../helpers/nginx-util.nix) { inherit lib pkgs; };
  proxyCfg = config.services.nginxProxy;
  proxyPathOpts = { name, ... }: {
    options = {
      serverHost = mkOption {
        description = "The host for the generated server block";
        default = "${name}.${proxyCfg.serverHost}";
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
      proto = mkOption {
        description = "The protocol to connect to the host with";
        default = "http";
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
      useAuthCookie = mkOption {
        description = "Whether or not to store the auth header in a session cookie (to fix issues with subpar browsers not sending the auth header with every request)";
        default = false;
        type = types.bool;
      };
    };
  };
  authCookieName = "nginx_auth";
in
{
  options.services.nginxProxy = {
    enable = mkEnableOption "Enable custom nginx config intended for reverse proxy";
    paths = mkOption {
      description = "Set of paths that will be proxied (without leading/trailing slashes)";
      type = types.attrsOf (types.submodule proxyPathOpts);
      default = { };
    };
    serverHost = mkOption {
      description = "The top level hostname for the generated server block, this is also used for the useACMEHost option.";
      type = types.str;
    };
    defaultServerACMEHost = mkOption {
      description = "The ACME host to use for the default server block (when accessing nginx via a wrong/missing domain)";
      default = proxyCfg.serverHost;
      type = types.str;
    };
    defaultRedirect = mkOption {
      description = "Where to redirect requests to the top level serverHost domain";
      default = "https://blog.withsam.org";
      type = types.str;
    };
  };

  config = mkIf proxyCfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    users.groups.acme.members = [ "nginx" ];

    services.nginx = {
      enable = true;

      additionalModules = [ pkgs.nginxModules.moreheaders ];

      commonHttpConfig = ''
        map $http_authorization $auth_header_from_cookie {
          default "$http_authorization";
          "" "$cookie_${authCookieName}";
        }
        ${util.errorPageHttpConfig}
      '';

      appendHttpConfig = ''
        charset utf-8;

        map $request_length $request_length_fmt {
          "~(.*)(.)(..).{4}$" "$1$2.$3M";
          "~(.*)(.)(.).{2}$" "$1$2.$3K";
          default "''${request_length}B";
        }

        map $bytes_sent $bytes_sent_fmt {
          "~(.*)(.)(..).{4}$" "$1$2.$3M";
          "~(.*)(.)(.).{2}$" "$1$2.$3K";
          default "''${bytes_sent}B";
        }

        log_format main '$remote_addr (fw:$http_x_forwarded_for) [$host] u:$remote_user '
          '"$request" $status '
          '[t:''${request_time}s ut:''${upstream_response_time} in:$request_length_fmt out:$bytes_sent_fmt] '
          're:"$http_referer" ua:"$http_user_agent"';
        access_log syslog:server=unix:/dev/log main;

        proxy_headers_hash_bucket_size 128;
        proxy_headers_hash_max_size 1024;
      '';

      virtualHosts = mkMerge ([
        {
          # default server block (i.e. wrong/no domain)
          "_" = {
            default = true;
            addSSL = true;
            useACMEHost = proxyCfg.defaultServerACMEHost;

            extraConfig = util.gzipBombConfig;
          };

          "www.${proxyCfg.serverHost}" = {
            useACMEHost = proxyCfg.serverHost;
            forceSSL = true;
            extraConfig = ''
              rewrite ^/$ https://${proxyCfg.serverHost} permanent;
            '';
          };

          "${proxyCfg.serverHost}" = util.addErrorPageOpts {
            useACMEHost = proxyCfg.serverHost;
            forceSSL = true;
            root = "/dev/null";

            locations = {
              "/".extraConfig = ''
                rewrite ^ ${proxyCfg.defaultRedirect};
              '';
            };
          };
        }
      ] ++ (
        mapAttrsToList
          (path: opts: {
            "${opts.serverHost}" = util.addErrorPageOpts {
              useACMEHost = proxyCfg.serverHost;
              forceSSL = true;
              extraConfig = opts.extraServerConfig;
              locations."= /favicon.ico".extraConfig = lib.mkForce "try_files _ @default;";
              locations."/".extraConfig = ''
                ${optionalString (opts.useAuth && opts.useAuthCookie)''
                more_set_input_headers "Authorization: $auth_header_from_cookie";
                ''}

                try_files _ @default;
              '';
              locations."@default".extraConfig = ''
                ${optionalString opts.useAuth ''
                auth_basic "${opts.authMessage}";
                auth_basic_user_file /var/lib/secrets/nginx/auth/${path}.htpasswd;
                ''}

                ${optionalString (opts.useAuth && opts.useAuthCookie)''
                add_header Set-Cookie "${authCookieName}=$http_authorization; Path=/; SameSite=Strict; Secure";
                ''}

                proxy_pass ${opts.proto}://${opts.host}:${toString opts.port};
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
