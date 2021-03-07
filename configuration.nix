# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports = [
    ./hardware-configuration.nix
    ./nvim.nix
    ./nginx.nix
    ./torrentvpn.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # Static IP
  networking.hostName = "hanzo";
  networking = {
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "5.9.43.79";
      prefixLength = 27;
    }];
    defaultGateway.address = "5.9.43.65";
    defaultGateway.metric = 10;
    nameservers = [ "213.133.98.98" "8.8.8.8" ];
  };

  time.timeZone = "UTC";

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];

  # Groups
  users.groups.storage = {};

  # User accounts
  users.users = {
    sam = {
      isNormalUser = true;
      extraGroups = [ "wheel" "storage" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIzlWx6yy2nWV8fYcIm9Laap8/KxAlLJd943TIrcldSY archdesktop"
      ];
    };
    syncthing = {
      extraGroups = [ "storage" ];
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09";

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    lm_sensors
    git
    wget
    tree
    file
    htop
    gcc
    sshfs
    tmux
    ffmpeg
    openssl
  ];

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "syncthing";
    group = "storage";
    dataDir = "/home/syncthing";
    configDir = "/home/syncthing/.config/syncthing";
    openDefaultPorts = true;
  };

  services.nginxProxy.paths = {
    "syncthing" = {
      port = 8384;
      authMessage = "What are you doing in my \"swamp\"?!";
    };
  };
}

# vim:et:sw=2