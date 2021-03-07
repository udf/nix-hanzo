{ config, lib, pkgs, ... }:

let
  statusCodes = import ./http-status-codes.nix;
  mapAttrsToStr = sep: fn: set: lib.strings.concatStringsSep sep (lib.mapAttrsToList fn set);
in
{
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

      locations."/error.html".extraConfig = ''
        ssi on;
        internal;
      '';

      locations."/food".extraConfig = ''
        return 410;
      '';
    };
  };
}
