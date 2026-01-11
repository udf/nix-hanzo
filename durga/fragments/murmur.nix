{ config, lib, pkgs, ... }:
let
  port = 64738;
  private = import ../../_common/constants/private.nix;
in
{
  systemd.services.murmur.after = [ "acme-renew-durga.withsam.org.timer" ];

  services.murmur = {
    enable = true;
    welcometext = "Congratulation! You have earned one (1) autism!";
    bandwidth = 144000;
    password = private.murmurPassword;
    sslCert = "/var/lib/acme/durga.withsam.org/fullchain.pem";
    sslKey = "/var/lib/acme/durga.withsam.org/key.pem";
  };

  users.groups.acme.members = [ "murmur" ];

  networking.firewall = {
    allowedUDPPorts = [ port ];
    allowedTCPPorts = [ port ];
  };
}
