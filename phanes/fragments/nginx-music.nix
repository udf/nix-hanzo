{ config, lib, pkgs, ... }:
let
  serverHost = (import ../../_common/constants/private.nix).homeHostname;
  util = (import ../../_common/helpers/nginx-util.nix) { inherit lib; };
in
{
  services.nginx.virtualHosts = {
    "music.${serverHost}" = util.addErrorPageOpts {
      useACMEHost = serverHost;
      forceSSL = true;
      root = "/var/www/music";
      locations = {
        "~ .*/$".extraConfig = ''
          autoindex on;
          auth_basic "Welcome to the sam zone";
          auth_basic_user_file /var/lib/secrets/nginx/auth/music.htpasswd;
        '';
      };
    };
  };
}
