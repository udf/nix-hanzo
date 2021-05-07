# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  vpnConsts = import ./constants/vpn.nix;
in
{
  imports = [
    ./hardware-configuration-dionysus.nix

    # core
    ./fragments/users.nix

    # programs
    ./fragments/nvim.nix
    ./fragments/zsh.nix
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
      address = vpnConsts.serverIP;
      prefixLength = 24;
    }];
    defaultGateway.address = "104.244.77.1";
    defaultGateway.metric = 10;
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  networking.nat = {
    enable = true;
    externalInterface = "eth0";
    internalInterfaces = [ "wg0" ];
  };
  networking.firewall = {
    allowedTCPPorts = [ vpnConsts.torrentListenPort ];
    allowedUDPPorts = [ vpnConsts.serverPort vpnConsts.torrentListenPort ];
  };

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 69 ];
    openFirewall = true;
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    git
    wget
    tree
    file
    htop
    sshfs
    tmux
    python39
  ];

  networking.wireguard.interfaces = {
    wg0 = (import ./helpers/wireguard-port-forward.nix {
      lib = lib;
      pkgs = pkgs;
      interface = "wg0";
      externalInterface = "eth0";
      gatewayIP = vpnConsts.gatewayIP;
      gatewaySubnet = "10.100.0.0/24";
    }) {
      ips = [ "${vpnConsts.gatewayIP}/24" ];
      listenPort = vpnConsts.serverPort;
      privateKeyFile = "/root/wireguard-keys/private";

      forwardedTCPPorts = {
        "${toString vpnConsts.torrentListenPort}" = vpnConsts.torrentContainerIP;
      };
      forwardedUDPPorts = {
        "${toString vpnConsts.torrentListenPort}" = vpnConsts.torrentContainerIP;
      };

      peers = [
        {
          # hanzo torrent container
          publicKey = "ltOCgajrsyWKJKuVtG9RFMWJNzSxg8tUxossPT3Nfkw=";
          allowedIPs = [ "${vpnConsts.torrentContainerIP}/32" ];
        }
      ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}

