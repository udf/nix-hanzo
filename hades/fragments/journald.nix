{ config, lib, pkgs, ... }:
{
  services.journald.extraConfig = ''
    MaxRetentionSec=1week
    SystemMaxUse=500M
  '';
}
