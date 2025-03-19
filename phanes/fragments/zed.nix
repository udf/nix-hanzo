{ config, lib, pkgs, ... }:
{
  services.zfs.zed = {
    settings = {
      ZED_EMAIL_ADDR = [ "root" ];
      ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
      ZED_EMAIL_OPTS = "@ADDRESS@";
      ZED_NOTIFY_INTERVAL_SECS = 3600;
    };
    enableMail = false;
  };
  custom.msmtp-gmail.enable = true;
}
