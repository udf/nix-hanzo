{ ... }:
{
  imports = [
    ../modules/zfs-auto-scrub.nix
  ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.extraModprobeConfig = ''
    options zfs l2arc_mfuonly=0
    options zfs l2arc_noprefetch=0
    options zfs l2arc_trim_ahead=50
    options zfs l2arc_meta_percent=100
    options zfs l2arc_headroom=4
    options zfs l2arc_write_max=${toString (32 * 1024 * 1024)}
    options zfs zfs_arc_max=${toString (8 * 1024 * 1024 * 1024)}
    options zfs zfs_arc_shrinker_limit=0
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
  custom.msmtp-gmail.enable = true;

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
}