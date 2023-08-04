{ config, lib, pkgs, ... }:
let 
  private =  (import ../../_common/constants/private.nix).ananke;
in
{
  services.ddclient = {
    enable = false;
    protocol = "ovh";
    use = "web, web=api.ipify.org";
    ssl = true;
    server = "www.ovh.com";
    username = "withsam.org-ananke";
    passwordFile = "/var/lib/secrets/ovh-ananke-dynhost";
    domains = [
      "${private.ddclientSubdomain}.withsam.org"
    ];
  };
}