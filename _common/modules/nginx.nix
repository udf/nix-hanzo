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

          #js_import sl_helper from ${../helpers/secure_link_helper.js};

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
                ${util.errorPageDirectives}
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
