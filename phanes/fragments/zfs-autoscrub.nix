{ config, lib, pkgs, ... }:
{
  services.zfs.autoScrub = {
    enable = true;
    interval = "*-*-15 00:00:00";
  };
}
