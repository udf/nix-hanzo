# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

with lib;
let
  private = import ../_common/constants/private.nix;
  vpnConsts = config.consts.vpn;
in
{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
    ../_common/constants/vpn.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  # Set your time zone.
  time.timeZone = "UTC";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Static IP
  networking.hostName = "dionysus";
  networking = {
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = private.dionysusIPv4;
      prefixLength = 24;
    }];
    interfaces.eth0.ipv6.addresses = [{
      address = private.dionysusIPv6;
      prefixLength = 48;
    }];
    defaultGateway6 = {
      address = "2605:6400:30::1";
      interface = "eth0";
    };
    defaultGateway.address = "104.244.77.1";
    defaultGateway.metric = 10;
    nameservers = [ "1.1.1.1" ];
  };

  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };
  networking.firewall =
    let
      getClientAttrValues = (attr: concatMap (cfg: attrValues cfg."${attr}") (attrValues vpnConsts.clients));
    in
    {
      allowedTCPPorts = (getClientAttrValues "forwardedTCPPorts");
      allowedUDPPorts = [ vpnConsts.serverPort ] ++ (getClientAttrValues "forwardedUDPPorts");
      logRefusedConnections = false;
    };
  networking.dhcpcd.enable = false;

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
  };

  # Fix DoS when too many nat connections are open
  boot.kernel.sysctl = {
    "net.netfilter.nf_conntrack_max" = 65536;
    "net.netfilter.nf_conntrack_generic_timeout" = 120;
    "net.netfilter.nf_conntrack_tcp_timeout_established" = 21600;
  };

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    openFirewall = true;
  };
  custom.fail2endlessh.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    sshfs
  ];

  networking.wireguard.interfaces =
    let
      getPorts =
        let
          mergeSets = (s: fold mergeAttrs { } s);
        in
        attr: (mergeSets (forEach
          (attrValues vpnConsts.clients)
          (cfg: mapAttrs' (_: port: nameValuePair (toString port) cfg.ip) cfg."${attr}"))
        );
    in
    {
      wg0 = (import ./helpers/wireguard-port-forward.nix {
        lib = lib;
        pkgs = pkgs;
        interface = "wg0";
        externalInterface = "eth0";
        gatewayIP = vpnConsts.gatewayIP;
        gatewaySubnet = vpnConsts.gatewaySubnet;
      }) {
        ips = [ "${vpnConsts.gatewayIP}/24" ];
        listenPort = vpnConsts.serverPort;
        privateKeyFile = "/root/wireguard-keys/private";

        forwardedTCPPorts = getPorts "forwardedTCPPorts";
        forwardedUDPPorts = getPorts "forwardedUDPPorts";

        peers = forEach (attrValues vpnConsts.clients) (cfg: {
          publicKey = cfg.publicKey;
          allowedIPs = [ "${cfg.ip}/32" ];
        });
      };
    };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

