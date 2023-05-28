{ config, lib, pkgs, ... }:
let
  private = (import ../../_common/constants/private.nix).hades;
in
{
  services.pppd = {
    enable = true;
    peers.home.config = ''
      plugin pppoe.so

      eth0
      name "${private.pppUsername}"
      password "${private.pppPassword}"
      usepeerdns
      persist
      defaultroute
      hide-password
      mtu 1420
      unit 0
    '';
  };
}
