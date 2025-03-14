{ config, lib, pkgs, ... }:
with lib;
let
  util = (import ../helpers/nginx-util.nix) { inherit lib; };
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
    defaultRedirect = mkOption {
      description = "Where to redirect requests to the top level serverHost domain";
      default = "https://blog.withsam.org";
      type = types.str;
    };
  };

  config = mkIf proxyCfg.enable {
    custom.ipset-block.exceptPorts = [ 443 ];

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
      '';

      appendHttpConfig =
        let
          lines = concatStringsSep "\n" (mapAttrsToList (k: v: "${k} ${lib.strings.escapeNixString v};") util.statusCodes);
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
        '';

      virtualHosts = mkMerge ([
        {
          # default server block (i.e. wrong/no domain)
          "_" = {
            default = true;
            addSSL = true;
            useACMEHost = proxyCfg.serverHost;
            root = "/var/www";

            extraConfig = ''
              types { } default_type "text/plain; charset=utf-8";
              add_header Content-Encoding "gzip, gzip";
              try_files /100g_9_9.gzip.gzip =444;
            '';
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
              locations."= /favicon.ico".extraConfig = "try_files _ @default;";
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
