{ config, lib, pkgs, ... }:
let
  serverHost = (import ../../_common/constants/private.nix).homeHostname;
in
{
  services.nginxProxy = {
    enable = true;
    serverHost = serverHost;
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "${serverHost}" = {
        email = "tabhooked@gmail.com";
        extraDomainNames = [ "*.${serverHost}" ];
        dnsProvider = "ovh";
        credentialsFile = "/var/lib/secrets/ovh.certs.secret";
      };
    };
  };
}
