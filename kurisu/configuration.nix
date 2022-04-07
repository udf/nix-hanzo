# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, options, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ../_autoload.nix ./.)
    ../_shared/fragments/msmtp-gmail.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.extraModprobeConfig = ''
    options zfs l2arc_mfuonly=0
    options zfs l2arc_noprefetch=0
    options zfs l2arc_trim_ahead=50
    options zfs l2arc_meta_percent=100
    optionz zfs l2arc_headroom=4
    options zfs l2arc_write_max=${toString (32 * 1024 * 1024)}
    options zfs zfs_arc_max=${toString (8 * 1024 * 1024 * 1024)}
  '';
  nixpkgs.config.packageOverrides = pkgs: {
    zfs = pkgs.zfs.override { enableMail = true; };
  };
  services.zfs.zed = {
    enableMail = true;
    settings = {
      ZED_EMAIL_ADDR = "tabhooked@gmail.com";
      ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";
      ZED_NOTIFY_INTERVAL_SECS = 600;
      ZED_NOTIFY_VERBOSE = true;
      ZED_NOTIFY_DATA = true;
      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = false;
    };
  };
  services.zfs-auto-scrub = {
    booty = "Sat *-*-* 01:00:00";
    backups = "Sun *-*-* 01:00:00";
  };
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p -u";
    frequent = 0;
    hourly = 24 * 7;
    daily = 30;
    weekly = 0;
    monthly = 0;
  };
  systemd.timers = {
    # why do they generate the units when the amount is set to 0?
    zfs-snapshot-frequent.enable = false;
    zfs-snapshot-weekly.enable = false;
    zfs-snapshot-monthly.enable = false;
  };

  # Trim because l2arc is hungry
  services.fstrim = {
    enable = true;
    interval = "daily";
  };

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
  system.stateVersion = "20.09";

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

  utils.storageDirs = {
    storagePath = "/booty";
    adminUsers = [ "sam" ];
    dirs = {
      music = { path = "/backups/music"; };
      backups = { path = "/backups"; };
      downloads = { };
    };
  };

  services.endlessh = {
    enable = true;
    port = 22;
    messageDelay = 3600;
    openFirewall = true;
  };

  services.syncplay = {
    enable = true;
  };
  systemd.services.syncplay.environment = {
    SYNCPLAY_PASSWORD = "hentai";
  };
  networking.firewall.allowedTCPPorts = [ config.services.syncplay.port 10800 ];

  networking.nat = {
    enable = true;
    externalInterface = "eth0";
  };
}

# vim:et:sw=2
