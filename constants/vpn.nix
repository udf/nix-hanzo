{ config, lib, pkgs, ... }:
with lib;
let
  private = import ./private.nix;
  clientCfgOpts= {...}: {
    options = {
      publicKey = mkOption {
        description = "Client public key";
        type = types.str;
      };
      ip = mkOption {
        description = "Client IP address";
        type = types.str;
      };
      forwardedTCPPorts = mkOption {
        description = "TCP ports to forward";
        type = types.attrsOf types.port;
        default = {};
      };
      forwardedUDPPorts = mkOption {
        description = "UDP ports to forward";
        type = types.attrsOf types.port;
        default = {};
      };
    };
  };
  vpnCfg = config.consts.vpn;
in
{
  options.consts.vpn = {
    serverPublicKey = mkOption {
      description = "VPN Server public key";
      type = types.str;
    };
    serverIP = mkOption {
      description = "VPN Server IP address";
      type = types.str;
    };
    serverPort = mkOption {
      description = "VPN Server port";
      type = types.port;
    };
    gatewaySubnet = mkOption {
      description = "VPN interface gateway subnet";
      type = types.str;
    };
    gatewayIP = mkOption {
      description = "VPN interface gateway IP address";
      type = types.str;
    };
    clients = mkOption {
      description = "Set of VPN clients";
      type = types.attrsOf (types.submodule clientCfgOpts);
    };
  };

  config.consts.vpn = {
    serverPublicKey = "nJnRKVLUwW+D2h/rhbF0o69IWfccK/8SJJuNvg7GkgA=";
    serverIP = private.dionysusIPv4;
    serverPort = 51820;
    gatewaySubnet = "10.100.0.0/24";
    gatewayIP = "10.100.0.1";
    clients = {
      torrents = {
        publicKey = "ltOCgajrsyWKJKuVtG9RFMWJNzSxg8tUxossPT3Nfkw=";
        ip = "10.100.0.2";
        forwardedTCPPorts = { torrentListen = 10810; };
        forwardedUDPPorts = { torrentListen = 10810; };
      };
      hath = {
        publicKey = "kh7Tw+GLtUWMS+eYDHZOzCkm/cQ8kRuGSRC3+iHpng0=";
        ip = "10.100.0.3";
        forwardedTCPPorts = { hath = 6969; };
      };
      tg-spam = {
        publicKey = "+41lQrWtn66Q/Gv4jQxyb9s/wUqvRD5M42oBoQntPCk=";
        ip = "10.100.0.4";
      };
      desktop = {
        publicKey = "z5oHAMmuI9ewM9aaZtzTl7EFm09AIKO74IPsUCSy2wk=";
        ip = "10.100.0.5";
      };
    };
  };
}