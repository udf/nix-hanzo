{ config, lib, pkgs, ... }:
let
  private = (import ../../_common/constants/private.nix).hades;
in
{
  services.hostapd = {
    enable = true;
    interface = "wlan0";
    hwMode = "g";
    ssid = "Hades";
    wpaPassphrase = private.passphrase;
    noScan = true;
    channel = 7;
    extraConfig = ''
      ht_capab=[SHORT-GI-20][SHORT-GI-40][TX-STBC][DELAYED-BA][LSIG-TXOP-PROT]
    '';
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    servers = [
      "1.1.1.1"
    ];
    extraConfig = ''
      interface=wlan0
      listen-address=10.0.0.1
      dhcp-range=10.0.0.2,10.0.0.150,12h
      dhcp-option=6,10.0.0.1
    '';
  };

  networking.nat = {
    enable = true;
    externalInterface = "ppp0";
    internalIPs = [
      "10.0.0.0/24"
    ];
  };

  networking.firewall.trustedInterfaces = [ "wlan0" ];
}
