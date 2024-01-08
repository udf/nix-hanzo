{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.custom.rpi-swapfile;
in
{
  options.custom.rpi-swapfile = {
    enable = mkEnableOption "Enable swapfile without swappiness (for rpi)";
    disableSwappiness = mkOption {
      type = types.bool;
      default = true;
      description = "Set vm.swappiness to zero";
    };
  };

  config = mkIf cfg.enable {
    swapDevices = [{ device = "/swapfile"; size = 4096; }];
    boot.kernel.sysctl = mkIf cfg.disableSwappiness {
      "vm.swappiness" = 0;
    };
  };
}
