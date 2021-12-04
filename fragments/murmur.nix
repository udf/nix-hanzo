{ config, lib, pkgs, ... }:
let
  port = 64738;
  private = import ../constants/private.nix;
in
{
  services.murmur = {
    enable = true;
    welcometext = "Congratulation! You have earned one (1) autism!";
    bandwidth = 144000;
    password = private.murmurPassword;
    sslCert = "/var/lib/acme/tsunderestore.io/fullchain.pem";
    sslKey = "/var/lib/acme/tsunderestore.io/key.pem";
  };

  users.groups.nginx.members = [ "murmur" ];

  networking.firewall = {
    allowedUDPPorts = [ port ];
    allowedTCPPorts = [ port ];
  };
}