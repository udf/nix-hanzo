{ config, lib, pkgs, ... }:

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
      up = ''
        ip route add 10.8.0.0/24 dev tun0 src 10.8.0.2 table tun0
        ip route add default via 10.8.0.1 dev tun0 table tun0
        ip rule add from 10.8.0.2/32 table tun0
        ip rule add to 10.8.0.2/32 table tun0
      '';
      down = ''
        ip route del 10.8.0.0/24 dev tun0 src 10.8.0.2 table tun0
        ip route del default via 10.8.0.1 dev tun0 table tun0
        ip rule del from 10.8.0.2/32 table tun0
        ip rule del to 10.8.0.2/32 table tun0
      '';
    };
  };

}