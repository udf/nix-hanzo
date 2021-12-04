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
  };

  networking.firewall = {
    allowedUDPPorts = [ port ];
    allowedTCPPorts = [ port ];
  };
}