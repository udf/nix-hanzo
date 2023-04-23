{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.rpi-remote-build-durga;
in
{
  options.custom.rpi-remote-build-durga = {
    enable = mkEnableOption "Enable using Oracle Cloud (durga) as a remote aarch64 builder";
  };

  config = mkIf cfg.enable {
    nix = {
      buildMachines = [{
        hostName = "durga";
        system = "aarch64-linux";
        maxJobs = 4;
        speedFactor = 10;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }];
      distributedBuilds = true;
      extraOptions = ''
        builders-use-substitutes = true
      '';
    };
  };
}
