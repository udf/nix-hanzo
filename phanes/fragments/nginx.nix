{ config, lib, pkgs, ... }:
let
  defaultServerHost = "churro.withsam.org";
  serverHost = (import ../../_common/constants/private.nix).homeHostname;
in
{
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
        extraDomainNames = [ "*.${serverHost}" "trans-rights.withsam.org" ];
        dnsProvider = "ovh";
        credentialsFile = "/var/lib/secrets/ovh.certs.secret";
      };
    };
  };
}
