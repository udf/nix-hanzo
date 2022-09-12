# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, options, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Static IP
  networking.hostName = "kurisu";
  networking = {
    hostId = "f1d1df42";
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "176.9.120.252";
      prefixLength = 27;
    }];
    interfaces.eth0.ipv6.addresses = [{
      address = "2a01:4f8:151:74ca:dab:dab:dab:dab";
      prefixLength = 64;
    }];
    defaultGateway.address = "176.9.120.225";
    defaultGateway.metric = 10;
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    nameservers = [ "213.133.98.98" "8.8.8.8" ];
    firewall.logRefusedConnections = false;
    dhcpcd.enable = false;
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "Fri *-*-* 20:00:00";
  };

  # tfw no console access
  systemd.enableEmergencyMode = false;

  time.timeZone = "UTC";

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 69 ];
    openFirewall = true;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.05";

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    ffmpeg
    atool
    unzip
  ];

  # Add local clone to NIX_PATH
  # nix.nixPath = options.nix.nixPath.default ++ [
  #   "nixpkgs-master=/home/sam/nixpkgs"
  # ];
  services.backup-root.excludePaths = [ "/home/sam/nixpkgs" ];

  services.syncplay = {
    enable = true;
  };
  systemd.services.syncplay.environment = {
    SYNCPLAY_PASSWORD = "hentai";
  };
  networking.firewall.allowedTCPPorts = [ config.services.syncplay.port ];

  networking.nat = {
    enable = true;
    externalInterface = "eth0";
  };

}

# vim:et:sw=2
