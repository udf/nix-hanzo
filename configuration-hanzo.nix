# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, options, ... }:

{
  imports = [
    ./hardware-configuration-hanzo.nix

    # modules
    ./modules/endlessh.nix

    # core
    ./fragments/system-packages.nix
    ./fragments/deterministic-ids.nix
    ./modules/storage-dirs.nix
    ./fragments/nginx.nix
    ./fragments/users.nix
    ./fragments/nix-options.nix
    ./modules/zfs-auto-scrub.nix

    # services
    ./modules/watcher-bot.nix
    ./fragments/syncthing.nix
    ./fragments/yt-music-dl.nix
    ./fragments/music-gain-tag.nix
    ./fragments/bbd-clients.nix
    ./fragments/airsonic.nix
    ./fragments/hvotebot.nix
    ./fragments/uniborg.nix
    # ./fragments/mc-server.nix
    #./fragments/factorio-server.nix
    ./fragments/torrent-container.nix
    ./fragments/hath-container.nix
    ./fragments/tg-spam-container.nix
    ./fragments/tagbot.nix
    ./fragments/stringifybot.nix
    ./fragments/murmur.nix
    ./fragments/nicotine-plus.nix

    # programs
    ./fragments/nvim.nix
    ./fragments/zsh.nix
    ./fragments/msmtp-gmail.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.extraModprobeConfig = ''
    options zfs l2arc_mfuonly=1
    options zfs l2arc_noprefetch=0
    options zfs l2arc_trim_ahead=50
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
  systemd.services.rsync-root = let
    snapshotServices = (map
      (n: "zfs-snapshot-${n}.service")
      (builtins.filter (n: config.services.zfs.autoSnapshot."${n}" > 0) ["hourly" "daily" "weekly" "monthly"])
    );
  in {
    description = "Backups root filesystem to the snapshot dataset";
    requiredBy = snapshotServices;
    before = snapshotServices;
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      ${pkgs.rsync}/bin/rsync \
        -aAXHxx \
        --delete \
        --exclude={/dev,/proc,/sys,/tmp,/run,/lost+found,/nix,/home/syncthing,/var/lib/containers/torrents/var/lib/qbittorrent/in_progress,/home/nicotine} \
        / /backups/snapshots/root/
    '';
  };

  # Trim because l2arc is hungry
  services.fstrim = {
    enable = true;
    interval = "daily";
  };

  # Static IP
  networking.hostName = "hanzo";
  networking = {
    hostId = "f1d1df42";
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "5.9.43.79";
      prefixLength = 27;
    }];
    defaultGateway.address = "5.9.43.65";
    defaultGateway.metric = 10;
    nameservers = [ "213.133.98.98" "8.8.8.8" ];
    firewall.logRefusedConnections = false;
  };

  nix.gc.automatic = true;

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

  utils.storageDirs = {
    storagePath = "/booty";
    adminUsers = [ "sam" ];
    dirs = {
      music = { path = "/backups/music"; };
      backups = { path = "/backups"; };
      downloads = {};
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
  networking.firewall.allowedTCPPorts = [ config.services.syncplay.port ];

  networking.nat = {
    enable = true;
    externalInterface = "eth0";
  }; 
}

# vim:et:sw=2