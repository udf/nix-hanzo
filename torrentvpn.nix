{ config, lib, pkgs, ... }:

let
  getStateChangeShell = action: ''
    ip route ${action} 10.8.0.0/24 dev tun0 src 10.8.0.2 table tun0
    ip route ${action} default via 10.8.0.1 dev tun0 table tun0
    ip rule ${action} from 10.8.0.2/32 table tun0
    ip rule ${action} to 10.8.0.2/32 table tun0
  '';
in
{
  networking = {
    iproute2.enable = true;
    iproute2.rttablesExtraConfig = ''
      2 tun0
    '';
  };

  services.openvpn.servers = {
    torrentVPN = {
      config = '' config /root/openvpn/torrentVPN.conf '';
      up = getStateChangeShell "add";
      down = getStateChangeShell "del";
    };
  };
}