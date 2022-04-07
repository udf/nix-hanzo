{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.custom.rpi-swapfile;
in
{
  options.custom.rpi-swapfile = {
    enable = mkEnableOption "Enable swapfile without swappiness (for rpi)";
  };

  config = mkIf cfg.enable {
    swapDevices = [{ device = "/swapfile"; size = 1024; }];
    boot.kernel.sysctl = {
      "vm.swappiness" = 0;
    };
  };
}
