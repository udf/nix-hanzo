{ config, lib, pkgs, ... }:
let
  defaultServerHost = "donut.withsam.org";
  serverHost = "durga.withsam.org";
  util = (import ../../_common/helpers/nginx-util.nix) { inherit lib pkgs; };
in
{
  custom.ipset-block.exceptPorts = [ 443 ];

  services.nginxProxy = {
    enable = true;
    serverHost = serverHost;
    defaultServerACMEHost = defaultServerHost;
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "${defaultServerHost}" = {
        email = "tabhooked@gmail.com";
        dnsProvider = "ovh";
        credentialsFile = "/var/lib/secrets/ovh.certs.secret";
      };
      "${serverHost}" = {
        email = "tabhooked@gmail.com";
        extraDomainNames = [
          "*.${serverHost}"
          "piracy.withsam.org"
          "music.withsam.org"
          "l.withsam.org"
        ];
        dnsProvider = "ovh";
        credentialsFile = "/var/lib/secrets/ovh.certs.secret";
      };
    };
  };

  services.nginx.virtualHosts = {
    "piracy.withsam.org" = util.addErrorPageOpts {
      useACMEHost = serverHost;
      forceSSL = true;
      root = "/var/www/files";
      extraConfig = "dav_ext_methods PROPFIND OPTIONS;";
      locations = {
        "/".extraConfig = ''
          ${util.denyWriteMethods}
          # prevent viewing directories without auth
          if ($request_method = PROPFIND) {
            rewrite ^(.*[^/])$ $1/ last; 
          }
        '';
        "~ .*/$".extraConfig = ''
          ${util.denyWriteMethods}
          autoindex on;
          auth_basic "Keep trying";
          auth_basic_user_file /var/lib/secrets/nginx/auth/files.htpasswd;
        '';
      };
    };

    "music.withsam.org" = util.addErrorPageOpts {
      useACMEHost = serverHost;
      forceSSL = true;
      root = "/var/www/files/music";
      extraConfig = "dav_ext_methods PROPFIND OPTIONS;";
      locations = {
        "/".extraConfig = ''
          ${util.denyWriteMethods}
          autoindex on;
          auth_basic "An otter in my water?";
          auth_basic_user_file /var/lib/secrets/nginx/auth/music.htpasswd;
        '';
      };
    };
  };
}
