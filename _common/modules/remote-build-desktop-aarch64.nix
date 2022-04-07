{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.rpi-remote-build-desktop;
in
{
  options.custom.rpi-remote-build-desktop = {
    enable = mkEnableOption "Enable using desktop as a remote aarch64 builder";
  };

  config = mkIf cfg.enable {
    nix = {
      buildMachines = [{
        hostName = "karen-chan";
        system = "aarch64-linux";
        maxJobs = 12;
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
